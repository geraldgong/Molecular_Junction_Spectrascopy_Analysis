clear all; close all; clc
[FileName,PathName] = uigetfile('/home/gong/E20/MJS/Data-Yuxiang/M3_2017/*.txt.',...
									'MultiSelect','off');
path(path, PathName)
data = load(FileName);
