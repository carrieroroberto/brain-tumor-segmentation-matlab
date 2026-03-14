function mask = region_growing(img, seed, tolerance)
    [rows, cols] = size(img);
    mask = false(rows, cols);
    
    seed_val = img(seed(1), seed(2));
    
    queue_r = zeros(rows * cols, 1);
    queue_c = zeros(rows * cols, 1);
    head = 1;
    tail = 1;
    
    queue_r(tail) = seed(1);
    queue_c(tail) = seed(2);
    mask(seed(1), seed(2)) = true;
    tail = tail + 1;
    
    dr = [-1, 1, 0, 0, -1, -1, 1, 1];
    dc = [0, 0, -1, 1, -1, 1, -1, 1];
    
    while head < tail
        curr_r = queue_r(head);
        curr_c = queue_c(head);
        head = head + 1;
        
        for i = 1:8
            neighbor_r = curr_r + dr(i);
            neighbor_c = curr_c + dc(i);
            
            if neighbor_r >= 1 && neighbor_r <= rows && ...
               neighbor_c >= 1 && neighbor_c <= cols
                
                if ~mask(neighbor_r, neighbor_c)
                    
                    diff = abs(img(neighbor_r, neighbor_c) - seed_val);
                    
                    if diff <= tolerance
                        mask(neighbor_r, neighbor_c) = true;
                        queue_r(tail) = neighbor_r;
                        queue_c(tail) = neighbor_c;
                        tail = tail + 1;
                    end
                end
            end
        end
    end
end