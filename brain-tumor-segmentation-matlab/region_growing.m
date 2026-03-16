function mask = region_growing(I, seedY, seedX, thresh)
    % IMPLEMENTAZIONE FROM SCRATCH: Region Growing (Breadth-First Search)
    [rows, cols] = size(I);
    mask = false(rows, cols);
    visited = false(rows, cols);
    
    % Pre-allocazione Coda (Queue) per efficienza in MATLAB
    max_pixels = rows * cols;
    Q_row = zeros(max_pixels, 1);
    Q_col = zeros(max_pixels, 1);
    
    head = 1;
    tail = 1;
    
    Q_row(tail) = seedY;
    Q_col(tail) = seedX;
    tail = tail + 1;
    
    mask(seedY, seedX) = true;
    visited(seedY, seedX) = true;
    
    dRow = [-1, 1, 0, 0, -1, -1, 1, 1];
    dCol = [0, 0, -1, 1, -1, 1, -1, 1];
    
    while head < tail
        currY = Q_row(head);
        currX = Q_col(head);
        head = head + 1;
        
        for i = 1:8
            nY = currY + dRow(i);
            nX = currX + dCol(i);
            
            if nY >= 1 && nY <= rows && nX >= 1 && nX <= cols
                if ~visited(nY, nX)
                    visited(nY, nX) = true;
                    
                    if I(nY, nX) > thresh
                        mask(nY, nX) = true;
                        
                        Q_row(tail) = nY;
                        Q_col(tail) = nX;
                        tail = tail + 1;
                    end
                end
            end
        end
    end
end