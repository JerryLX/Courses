# -*- coding: utf-8 -*-
#!/usr/bin/env python

"""
Calculate volume for each 20-minute time window.
"""
import math
from datetime import datetime,timedelta

file_suffix = '.csv'
path = '../'  # set the data directory

def calculate(in_file1, in_file2):


    in_file_name1 = in_file1 + file_suffix
    in_file_name2 = in_file2 + file_suffix

    # Step 1: Load volume data
    fr1 = open(in_file_name1, 'r')
    fr1.readline()  # skip the header
    vol_data1 = fr1.readlines()
    fr1.close()
    
    fr2 = open( in_file_name2, 'r')
    fr2.readline()  # skip the header
    vol_data2 = fr2.readlines()
    fr2.close()
    
    # Step 2: Create a dictionary to caculate and store volume per time window
    volumes1 = {}  # key: time window value: dictionary
    for i in range(len(vol_data1)):

        each_pass = vol_data1[i].replace('"', '').split(',')
        tollgate_id = int(each_pass[0])
        #print tollgate_id

        direction = each_pass[3]
        result = int(each_pass[4])
        pass_time = each_pass[1]+','+each_pass[2]
        
        if pass_time not in volumes1:
            volumes1[pass_time] = {1:{0:0,1:0},2:{0:0},3:{0:0,1:0}}
            
        volumes1[pass_time][tollgate_id][direction] = result
                
    volumes2 = {}  # key: time window value: dictionary
    for i in range(len(vol_data2)):
        each_pass = vol_data2[i].replace('"', '').split(',')
        tollgate_id = int(each_pass[0])
        direction = each_pass[3]
        result = int(each_pass[4])
        pass_time = each_pass[1]+','+each_pass[2]
        
        if pass_time not in volumes2:
            volumes2[pass_time] = {1:{0:0,1:0},2:{0:0},3:{0:0,1:0}}
            
        volumes2[pass_time][tollgate_id][direction] = result

    fw = open('result'+file_suffix, 'w')
    fw.writelines(','.join(['"predict"', '"target"']) + '\n')
    test_count = 0
    diff = 0.0
    for time in volumes1:
        for tollgate_id in volumes1[time]:
            for direction in volumes1[time][tollgate_id]:
                val1 = volumes1[time][tollgate_id][direction]
                val2 = volumes2[time][tollgate_id][direction]
                if val2 == 0:
                    continue
                test_count = test_count+1
                diff = diff+float(abs(val1 - val2))/val2
                out_line = ','.join(['"' + str(val1) + '"', 
                                 '"' + str(val2) + '"'
                               ]) + '\n'
                fw.writelines(out_line)
                           
    return diff/test_count

def main():

    in_file2 = 'training2_20min_avg_volume'
    in_file1 = 'test1result'
    mape = calculate(in_file1,in_file2)
    print mape

if __name__ == '__main__':
    main()



