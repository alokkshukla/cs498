%%
% 1) EM Topic models The UCI Machine Learning dataset repository hosts 
%   several datasets recording word counts for documents here. You will use
%   the NIPS dataset. You will find (a) a table of word counts per document
%   and (b) a vocabulary list for this dataset at the link. You must
%   implement the multinomial mixture of topics model, lectured in class.
%   For this problem, you should write the clustering code yourself (i.e. 
%   not use a package for clustering).

clc; clear; close all;
data = load('docword.nips.txt');
num_docs  = data(1,1);
num_words = data(1,2);

docs_2d = zeros(num_docs, num_words);
for idx = 2:length(data)
    datum = data(idx,:);
    docs_2d(datum(1), datum(2)) = datum(3);
end
sparse_docs = sparse(docs_2d);

num_segments = 30;
segments = rand(num_segments, num_words);
magnitude = sum(segments, 2);
for idx = 1:num_segments
    segments(idx, :) = segments(idx, :) / magnitude(idx);
end

pis = rand(num_segments, 1);
magnitude = sum(pis, 1);
pis = pis ./ magnitude;

clear data datum documents_2d idx magnitude;

%%
% a) Cluster this to 30 topics, using a simple mixture of multinomial topic
%   model, as lectured in class.

num_steps = 50;
w_per_pix = zeros(num_segments, num_docs);

w_per_pix_m_pix = zeros(num_segments, num_docs, num_words);

for step = 1:num_steps
    step
    for idx = 1:num_docs
        pix = sparse_docs(idx, :);
        w_per_pix(:, idx) = w_from(pix, segments, pis);
        w_per_pix_m_pix(:, idx, :) = w_per_pix(:, idx) * pix;
    end
    
    pis = sum(w_per_pix, 2) / num_docs;
    segments = squeeze(sum(w_per_pix_m_pix, 2));
    magnitude = sum(segments, 2);
    for idx = 1:num_segments
        segments(idx, :) = segments(idx, :) / magnitude(idx);
    end

end

'done'
%%
% b) Produce a graph showing, for each topic, the probability with which
%   the topic is selected.
figure;
stem(pis);
title('Probability vs Topic');
ylabel('Probability of Selection');
xlabel('Topic Number');

%%
% c) Produce a table showing, for each topic, the 10 words with the highest
%   probability for that topic.

vocab = importdata('vocab.nips.txt');

for idx = 1:length(segments(:, 1))
    topic = segments(idx, :);
    idx
    [~,indices] = sort(topic,'descend');
    vocab(indices(1:10))
end


%%
% 2) Image segmentation using EM You can segment an image using a 
%   clustering method - each segment is the cluster center to which a pixel
%   belongs. In this exercise, you will represent an image pixel by its r,
%   g, and b values (so use color images!). Use the EM algorithm applied to
%   the mixture of normal distribution model lectured in class to cluster
%   image pixels, then segment the image by mapping each pixel to the 
%   cluster center with the highest value of the posterior probability for
%   that pixel. You must implement the EM algorithm yourself (rather than
%   using a package). We will release a set of test images shortly; till
%   then, use any color image you care to.

clc; clear; close all;

num_pixels = 480*640;
num_channels = 3;

img1 = double(reshape(imread('img1.jpg'), [num_pixels num_channels]));
% img2 = reshape(imread('img2.jpg'), [num_pixels num_channels]);
% img3 = reshape(imread('img3.jpg'), [num_pixels num_channels]);

%%
% a) Segment each of the test images to 10, 20, and 50 segments. You should
%   display these segmented images as images, where each pixel's color is
%   replaced with the mean color of the closest segment

num_segments = 10;
img = img1;

segments = datasample(img, num_segments);

pis = rand(num_segments, 1);
magnitude = sum(pis, 1);
pis = pis ./ magnitude;

num_steps = 50;
w_per_pix = zeros(num_segments, num_pixels);
w_per_pix_m_pix = zeros(num_ssegegments, num_pixels, num_channels);

img_average = mean(img, 1);

for step = 1:num_steps
    step
    for idx = 1:num_pixels
        pix = img(idx, :);
        
        w = zeros(size(pis));
        for i = 1:length(pis)
            temp = pix - segments(i, :);
            w(i) = (-0.5) * (temp * temp');
        end
        w = w - max(w);
        w = exp(w);
        w = w .* pis;
        w = w / sum(w);
        
        w_per_pix(:, idx) = w;
        w_per_pix_m_pix(:, idx, :) = w_per_pix(:, idx) * pix;
    end    
    pis = sum(w_per_pix, 2) / num_pixels;
    segments = squeeze(sum(w_per_pix_m_pix, 2));
    magnitude = sum(w_per_pix, 2); 
    for idx = 1:num_segments
        segments(idx, :) = segments(idx, :) / magnitude(idx);
    end
end

'done'



%%
% b) We will identify one special test image. You should segment this to 20
%   segments using five different start points, and display the result for
%   each case. Is there much variation in the result?



