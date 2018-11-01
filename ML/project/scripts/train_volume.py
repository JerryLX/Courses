# -*- coding: utf-8 -*-
"""
Created on Wed May 31 13:13:49 2017

@author: Jerry
"""

import math
from sklearn.neural_network import MLPRegressor
from datetime import datetime,timedelta

file_suffix = '.csv'
path = '../'  # set the data directory

model_mlp = MLPRegressor(solver='lbfgs', hidden_layer_sizes=(10, 10), random_state=1)
X = []
Y = []
gap = 3
# training data format
# X format: tollgate_id, direction, time_window,time_window,time_window, date, weekday
# Y: volume
def trainRead(in_file):    
    in_file_name = in_file + file_suffix

    # Step 1: Load volume data
    fr = open(path + in_file_name, 'r')
    fr.readline()  # skip the header
    vol_data = fr.readlines()
    fr.close()

    # Step 2: Create a dictionary to caculate and store volume per time window
    volumes = {}  # key: time window value: dictionary
    for i in range(len(vol_data)):
        each_pass = vol_data[i].replace('"', '').split(',')
        tollgate_id = each_pass[1]
        direction = each_pass[2]

        pass_time = each_pass[0]
        pass_time = datetime.strptime(pass_time, "%Y-%m-%d %H:%M:%S")
        time_window_minute = int(math.floor(pass_time.minute / 20) * 20)
        #print pass_time
        start_time_window = datetime(pass_time.year, pass_time.month, pass_time.day,
                                     pass_time.hour, time_window_minute, 0)

        if start_time_window not in volumes:
            volumes[start_time_window] = {1:{0:0,1:0},2:{0:0},3:{0:0,1:0}}
                   
        tollgate_id = int(tollgate_id)
        direction = int(direction)
        volumes[start_time_window][tollgate_id][direction] += 1

    # Step 3: format output for tollgate and direction per time window
    time_windows = list(volumes.keys())
    time_windows.sort()
    current_date = current_time_window = time_windows[0]
    time_slots = [[],[],[],[],[]]
    time_window_end = time_windows[-1]
    for current_time_window in time_windows:
        current_time_window_end = current_time_window+timedelta(minutes=20)
    
        delta = current_time_window - current_date
        current_date = current_time_window
        if delta.seconds > 1200:
            time_slots = [[],[],[],[],[]]
        
        time_slots[0].append(volumes[current_time_window][1][0])
        time_slots[1].append(volumes[current_time_window][1][1])
        time_slots[2].append(volumes[current_time_window][2][0])
        time_slots[3].append(volumes[current_time_window][3][0])
        time_slots[4].append(volumes[current_time_window][3][1])
        
        #print time_slots[0]
        if len(time_slots[0]) < 3:
            continue
        
        if current_time_window == time_window_end:
            break
        
        for l in time_slots:
            l = [l[-3],l[-2],l[-1]]
        
        weekday = current_time_window.weekday()
        day = current_time_window.day
        
        for i in range(len(time_slots)):
            l = time_slots[i]
            if i == 0:
                current_x = [1,0,weekday,day,l[-3],l[-2],l[-1]]
            elif i==1:
                current_x = [1,1,weekday,day,l[-3],l[-2],l[-1]]
            elif i == 2:
                current_x = [2,0,weekday,day,l[-3],l[-2],l[-1]]
            elif i==3:
                current_x = [3,0,weekday,day,l[-3],l[-2],l[-1]]
            else:
                current_x = [3,1,weekday,day,l[-3],l[-2],l[-1]]
                
            if current_time_window.hour <  12:
                current_x.append(1)
            else:
                current_x.append(0)
            X.append(current_x)
        
        Y.append(volumes[current_time_window_end][1][0])
        Y.append(volumes[current_time_window_end][1][1])
        Y.append(volumes[current_time_window_end][2][0])
        Y.append(volumes[current_time_window_end][3][0])
        Y.append(volumes[current_time_window_end][3][1])
    
    
def test(in_file):
    in_file_name = in_file + file_suffix
    out_file_name = in_file.split('_')[1] + 'result' + file_suffix
    fw = open(out_file_name, 'w')
    fw.writelines(','.join(['"tollgate_id"', '"time_window"', '"direction"', '"volume"']) + '\n')
    # Step 1: Load test data
    fr = open(path + in_file_name, 'r')
    fr.readline()  # skip the header
    vol_data = fr.readlines()
    fr.close()
    
    # Step 2: Create a dictionary to caculate and store volume per time window
    volumes = {}  # key: time window value: dictionary
    for i in range(len(vol_data)):
        each_pass = vol_data[i].replace('"', '').split(',')
        tollgate_id = each_pass[1]
        direction = each_pass[2]

        pass_time = each_pass[0]
        pass_time = datetime.strptime(pass_time, "%Y-%m-%d %H:%M:%S")
        time_window_minute = int(math.floor(pass_time.minute / 20) * 20)
        #print pass_time
        start_time_window = datetime(pass_time.year, pass_time.month, pass_time.day,
                                     pass_time.hour, time_window_minute, 0)

        if start_time_window not in volumes:
            volumes[start_time_window] = {1:{0:0,1:0},2:{0:0},3:{0:0,1:0}}
                   
        tollgate_id = int(tollgate_id)
        direction = int(direction)
        volumes[start_time_window][tollgate_id][direction] += 1
               
               
    time_windows = list(volumes.keys())
    time_windows.sort()
    first_day = time_windows[0]
    for current_time_window in time_windows:
        if current_time_window.hour !=7 and current_time_window != 16:
            continue
        if current_time_window.minute != 0:
            continue
        
        time_slots = [[],[],[],[],[]]
        temp = current_time_window
        for i in range(3):
            time_slots[0].append(volumes[temp][1][0])
            time_slots[1].append(volumes[temp][1][1])
            time_slots[2].append(volumes[temp][2][0])
            time_slots[3].append(volumes[temp][3][0])
            time_slots[4].append(volumes[temp][3][1])
            temp = temp+timedelta(minutes=20)
    
               
        weekday = current_time_window.weekday()
        day = current_time_window.day
        predict_time_window = current_time_window + timedelta(hours=1)
        
        for i in range(6):
            predict_time_window_end = predict_time_window + timedelta(minutes=20)
            for i in range(len(time_slots)):
                l = time_slots[i]
                if i == 0:
                    current_x = [1,0,weekday,day,l[-3],l[-2],l[-1]]
                    tollgate_id = 1
                    direction = 0
                elif i==1:
                    current_x = [1,1,weekday,day,l[-3],l[-2],l[-1]]
                    tollgate_id = 1
                    direction = 1
                elif i == 2:
                    current_x = [2,0,weekday,day,l[-3],l[-2],l[-1]]
                    tollgate_id = 2
                    direction = 0
                elif i==3:
                    current_x = [3,0,weekday,day,l[-3],l[-2],l[-1]]
                    tollgate_id = 3
                    direction = 0
                else:
                    current_x = [3,1,weekday,day,l[-3],l[-2],l[-1]]
                    tollgate_id = 3
                    direction = 1
                
                if current_time_window.hour <  12:
                    current_x.append(1)
                else:
                    current_x.append(0)
                    
                result = int(model_mlp.predict(current_x))
                out_line = ','.join(['"' + str(tollgate_id) + '"', 
			                     '"[' + str(predict_time_window) + ',' + str(predict_time_window_end) + ')"',
                                 '"' + str(direction) + '"',
                                 '"' + str(result) + '"',
                               ]) + '\n'
                
                fw.writelines(out_line)
                predict_time_window = predict_time_window_end
                l = [l[-2],l[-1],result]
    fw.close()
    
def main():

    in_file = 'volume(table 6)_training'
    trainRead(in_file)
    
    in_file = 'volume(table 6)_training2'
    trainRead(in_file)
    
    model_mlp.fit(X,Y)
    
    test_file = 'volume(table 6)_test1'
    test(test_file)
    
    test_file = 'volume(table 6)_test2'
    test(test_file)
if __name__ == '__main__':
    main()
