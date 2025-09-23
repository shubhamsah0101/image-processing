clc; clear all; close all;

% infrared image
ir = imread('walking_IR.jpg');
ir = rgb2gray(ir);
figure;
imshow(ir)

% visible image
vb = imread('walking_VI.jpg');
vb = rgb2gray(vb);
figure;
imshow(vb)