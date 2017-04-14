function [MovMat, GroundTruth,filename] = Loader(in_directory, gt_directory)

contents = dir([in_directory,'*.jpg']);
GT_cont  = dir([gt_directory,'*.png']);

for i = 1 : numel(contents)
    disp(i)
    filename{i} = contents(i).name; %#ok<*AGROW,*SAGROW>
    img         = imread([in_directory filename{i}]);
    img_gray    = rgb2gray(img);
    MovMat(:,:,i) = double(img_gray) / 255; %#ok<*NASGU>
    
    GT_filename = GT_cont(i).name;
    GT_i        = imread([gt_directory GT_filename]);
    GroundTruth(:,:,i) = double(GT_i) / 255;

end