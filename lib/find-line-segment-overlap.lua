-- Stack overflow answer. Refine solution.
-- https://stackoverflow.com/questions/45478638/intersection-or-overlap-of-two-line-segments

function find_line_segment_overlap (ax, ay, bx, by, cx, cy, dx, dy) -- start end start end
    if ax and ay and bx and by and cx and cy and dx and dy then
        local d = (ax-bx)*(cy-dy)-(ay-by)*(cx-dx)

        if d == 0 then
            return nil  -- they are parallel
        end

        local a, b = ax*by-ay*bx, cx*dy-cy*dx
        local x = (a*(cx-dx) - b*(ax-bx))/d
        local y = (a*(cy-dy) - b*(ay-by))/d

        if x <= math.max(ax, bx) and x >= math.min(ax, bx) and
            x <= math.max(cx, dx) and x >= math.min(cx, dx) then
            -- between start and end of both lines
            return {x = x, y = y}
        end
    end

    return nil
end
