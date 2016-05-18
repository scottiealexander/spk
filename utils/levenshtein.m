function d = levenshtein(s1,s2)

% levenshtein
%
% Description: computes the levenshtein distance between two strings
%			   (i.e. the number of insertions, deletions, substitutions 
%			   needed to transform s1 into s2)
%
% Syntax: dist = levenshtein(s1,s2)
%
% In: 
%		s1 - a string (1 x N char matrix)
%		s1 - another string (1 x N char matrix)
%
% Out:
%		dist - the levenshtein distance between s1 and s2
%
% Updated: 2014-03-25
% Scottie Alexander
%
% Sources: http://en.wikipedia.org/wiki/Levenshtein_distance
%
% Please report bugs to: scottiealexander11@gmail.com

m = length(s1);
n = length(s2);
d = zeros(m,n);

d(:,1) = 0:m-1;
d(1,:) = 0:n-1;
 
 for j = 2:n
 	for i = 2:m
		if s1(i-1) == s2(j-1)
			d(i, j) = d(i-1, j-1);    %no operation required
		else
			d(i, j) = min([
		          d(i-1, j) + 1,  ... % a deletion
		          d(i, j-1) + 1,  ... % an insertion
		          d(i-1, j-1) + 1 ... % a substitution
		        ]);
		end
    end            
end

d = d(m,n);