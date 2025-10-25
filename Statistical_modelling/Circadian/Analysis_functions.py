#!/usr/bin/env python
# coding: utf-8

"""
Utilities for loading/processing data from 
    binary files (outputted from margo)
Created on July 3rd 2019

@author: DL
"""

"""
Modified for circadian rhythm analysis
May 31, 2024
SL
"""

import array
import numpy as np
import pandas as pd
import hdf5storage
import bisect
from scipy import stats

import re
import os

MAX_N_FRAMES = 3*60*60*96 # 96 hours

##################################################
############ For loading in data from binary files
##################################################  


def read_in_centroids_and_time(centroid_bin_file, time_bin_file, NROI):
    '''
    Given binary files for centroid and time data,
    loads in the array for centroids (in shape n_frames * 2 * nROI),
    loads in the array for time (in shape n_frames*1)
    '''
    # read in time binary file 
    try:
        time_array = array.array("f")
        time_array.fromfile(open(time_bin_file, mode='rb'), MAX_N_FRAMES)
        # this is a trick! Let n be large, like the max number of frames. Then,
        # array.fromfile will read in up to n items. if n exceeds the number
        # of items in the actual file, a warning gets raised, but it'll still
        # load in the real number of items... so to suppress the warning, I
        # put this in a try: except and just return the object loaded with
        # however true items there are inside.
    except EOFError:
        time_array = np.array(time_array)
        
    if len(time_array) == 0:
        raise ValueError('time binary file is empty!')
           
    # read in centroids binary file with same process
    try:
        centroids = array.array("f")
        centroids.fromfile(open(centroid_bin_file, mode='rb'), NROI*2*MAX_N_FRAMES)
        
    except EOFError:
        n_frames = int(len(centroids) / NROI / 2)
        centroids = np.array(centroids).reshape((n_frames, 2, NROI))
        
    if len(centroids) == 0:
        raise ValueError('centroids binary file is empty!')

    return centroids, time_array

def convert_time(hours,minutes,seconds):
    '''
    Given HH,MM,SS
    convert to hours
    Used to convert start time to decimal
    '''
    
    min_to_hour = minutes / 60
    sec_to_hour = seconds / 60 / 60
    
    convert_hour = hours+min_to_hour+sec_to_hour
    
    return convert_hour
    
def get_frame_times(time_array, expmt_start_time):
    '''
    Given time_array (the time offset between frames outputted by margo tracking), 
    and experiment start time (in decimal hours)
    returns true times of frames (in hours)
    '''
    
    frame_times = expmt_start_time + np.cumsum(time_array) / 60 / 60
    
    return frame_times

def cull_cent_time(centroids,frame_times,ll,hours):
    ul = ll + hours
   
    lower_bound = bisect.bisect_left(frame_times, ll)
    upper_bound = bisect.bisect_right(frame_times, ul)
    
    frame_times_culled = frame_times[lower_bound:upper_bound]
    centroids_culled = centroids[lower_bound:upper_bound]

    return centroids_culled,frame_times_culled,
    
def get_activity_from_centroids_bin(centroids):
    '''
    Given centroids data (n_frames * 2 * nROI),
    returns speed (n_frames * nROI) by computing 
    COM distance between two consecutive frames.
    '''
    # initialize with zeros
    spds = np.zeros(shape=(centroids.shape[0], centroids.shape[2]))
    # spd(i) = sqrt( [ (x(i) -x(i-1) ]^2 + [ (y(i) -y(i-1) ]^2 )
    spds[1:, :] = np.sum(np.diff(centroids, axis=0)**2, axis=1)**(1/2)
    # finally, fill NaN's with 0
    return np.nan_to_num(spds) 


def make_dict_from_bin_files(centroid_bin_file, time_bin_file, expmt_start_time, NROI,ll,hours):
    '''
    Puts everything together, reading in centroid, time binary files,
    and returning a dictionary with the relevant information
    (speed array, times of frames)
    ll is lower limit of experiment start time - i.e., 21:00 ll and 84 hours will use data from 9PM on day 1 and 84 hours from there - i.e., 9AM on day 4
    '''
    # read in the binary data
    centroids, time_array = read_in_centroids_and_time(centroid_bin_file, time_bin_file, NROI)
    
    # use time array to get frame times
    frame_times = get_frame_times(time_array, expmt_start_time)

    #cull centroid & time data according to experiment
    centroids_culled, ts_culled = cull_cent_time(centroids,frame_times,ll,hours)
    
    #compute activity from centroids
    act = get_activity_from_centroids_bin(centroids_culled)
    
    # return relevant info in dictionary
    return {'activity': act,
          'ts': ts_culled}

def get_speed_from_activity(activity,tp):
    '''
    Given activity data (n_frames * nROI), and time points,
    returns speed (n_frames * nROI) by using activity =  
    euclidean distance between two consecutive frames and dividing by time elapsed.
    '''
    # initialize with zeros
    speed = np.zeros(shape=(activity.shape[0], activity.shape[1]))
    # spd(i) = activity/time_elapsed
    
    del_tp = np.ediff1d(tp,to_begin=0)
    
    speed[1:, :] = (activity[1:,:]/del_tp[1:,None])
    
    return speed

def exclude_dead_inactive(activity_matrix, NROI):
    '''
    Given activity matrix, excludes flies that had no activity
    '''
    
    zero_counts = np.count_nonzero(activity_matrix==0, axis=0)
    thresh = 0.9*activity_matrix.shape[0]
    
    ind = []
    for i in range(len(zero_counts)):
        if zero_counts[i] >= thresh:
            ind.append(i)
    activity_matrix_mod = np.delete(activity_matrix,ind,axis = 1)
    
    return activity_matrix_mod,ind

###Check###
def speed_avg_for_plots (mean_speed,sd_speed,frame_times, ts = 0.1):
    
    '''
    Given a K-sized array of mean and sd of speeds across all animals, creates a k-sized array of 
    mean and sd where k<K, at 0.1 hr timepoints, for better plot visualisations
    '''
    
    ll = np.floor(frame_times[0])
    ul = np.ceil(frame_times[-1])
    
    ITI_data = stats.mode([t - s for s, t in zip(frame_times, frame_times[1:])])[0]
    
    conv_ratio = ITI_data/ts
    
    time_points = np.arange(ll,ul,ts)
    
    avg_speeds_plot = np.zeros(len(time_points))
    var_speeds_plot = np.zeros(len(time_points))
    
    for i in range(len(time_points)-1):
        lower_bound = time_points[i]
        upper_bound = time_points[i+1]
        
        lower_bound_i = bisect.bisect_left(frame_times, lower_bound)
        upper_bound_i = bisect.bisect_right(frame_times, upper_bound, lo=lower_bound_i)
    
        sum_speed = np.sum(mean_speed[lower_bound_i:upper_bound_i])
        avg_speed = sum_speed*conv_ratio
        
        sum_sd_speed = np.sum(sd_speed[lower_bound_i:upper_bound_i])
        var_speed = sum_sd_speed*conv_ratio
        
        avg_speeds_plot[i] = avg_speed
        var_speeds_plot[i] = var_speed
    
    return avg_speeds_plot,var_speeds_plot, time_points




