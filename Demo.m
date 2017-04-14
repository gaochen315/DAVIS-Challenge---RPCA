%% Object Segmentation for EECS 542 final project
% video_RPCA
%--------------------------------------------------------------------------
% Description:  Separate video foreground and background via Robust PCA 
%               and Generate a foreground mask
%
% Inputs:       MovMat is a height * width * #frame video matrix.
%
%               [OPTIONAL] opts is a struct containing one or more of the
%               following fields. The default values are in ()
%
%                   opts.color (0) is the indicator whether MovMat is a
%                   colorful video.
%
%                   opts.method ('numeric') is the method used for selecting
%                   the anchor frame.
%                       'numeric' :   numeric middle frame
%
%                       'geometric': geometric middle frame
%
%                       If the input is numeric, then the number is
%                       indicating the anchor frame                
%
% Outputs:      RPCA_image: Low-rank panorama generated from video
%
%               L: Lowrank component video in original ratio
%
%               S: Sparse component video in original ratio
%
%               L_RPCA: Lowrank component video in global coordinate system
%
%               S_RPCA: Sparse component video in global coordinate system
%
% Requirement:  Matlab Computer vision toolbox
%
% Author:       Chen Gao
%               chengao@umich.edu
%
% Date:         April 13, 2017
%--------------------------------------------------------------------------

% Load video
clear all
in_directory = '/Users/chengao/Desktop/542 Final/DAVIS/JPEGImages/480p/tennis/';
gt_directory = '/Users/chengao/Desktop/542 Final/DAVIS/Annotations/480p/tennis/';

[MovMat_ori, GroundTruth, filename] = Loader(in_directory,gt_directory);


MovMat        = MovMat_ori(:,:,1 : 1 : 10);
GroundTruth   = GroundTruth(:,:,1 : 1 : 10);
num_of_frames = size(MovMat,3);


% Apply homography transformation to register frames
opts.maxIters = 200;
opts.adjust  = false;

[RPCA_image, L_ORIG, S_ORIG, ~, ~] = video_RPCA(MovMat,opts);
 
 
% Generate foreground mask simply by thresholding
MF      = abs(S_ORIG - 0.5) > 0.1;

% Cleaning mask
for i = 1 : size(MovMat,3)
 
    frame_mask  = MF(:,:,i);
    frame_mask1 = imerode(frame_mask,strel('disk',2,4));
    frame_mask2 = imdilate(frame_mask1,strel('disk',10,4));   
    frame_mask3 = bwlabel(frame_mask2);
    list = unique(frame_mask3);
    
    for j = 2 : length(list)
        test = (frame_mask3 == list(j));
        if sum(test(:)) < 5000
            frame_mask2(frame_mask3 == list(j)) = 0;
        end        
    end
    out1(:,:,i) = imclose(frame_mask2,strel('disk',2));
end
 
  
for i = 1 : size(MovMat,3)
    Jaccard(i,1) = sum(sum((double(GroundTruth(:,:,i)) & out1(:,:,i)))) / ...
                 sum(sum((double(GroundTruth(:,:,i)) | out1(:,:,i))));
end
 


