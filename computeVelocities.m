function [velXGrid, velYGrid] = computeVelocities(g,init_level,current,i)
    [velocityX,velocityY] = plasma(current,i)
    g.xs{1,1}
    vel{1,1} = zeros(size(g.xs{1,1}));
    vel{2,1} = zeros(size(g.xs{1,1}));
    dy = abs(g.xs{2,1} - init_level);
    dx = abs(g.xs{1,1})
    lambda1 = current(8); %Make into current parameter to be optimized
    lambda2 = current(9);
    v_sy = exp(-dy/lambda2)*-1*velocityY; %multiply by negative one to put in right direction
    v_sx = exp(-dx/lambda1)*velocityX;
    %make matrix with rows that decay exponentially symmetrically across 0
    assignin('base', 'dy', dy)
    assignin('base', 'dx', dx)
    assignin('base', 'v_sx', v_sx)
    assignin('base', 'v_sy', v_sy)
    vel{1,1}(g.xs{1,1}>-init_level & g.xs{1,1} < 0) = -v_sx(g.xs{1,1}>-init_level & g.xs{1,1} < 0);
    vel{1,1}(g.xs{1,1}>= 0 & g.xs{1,1} < init_level) = v_sx(g.xs{1,1}>= 0 & g.xs{1,1} < init_level);
    vel{2,1}(g.xs{2,1} > -init_level) = v_sy(g.xs{2,1} > -init_level);
    assignin('base', 'v_sx_assigned', vel{1,1})
    assignin('base', 'v_sy_assigned', vel{2,1})
    assignin('base', 'dy', dy)
    gridSize = (g.xs{1,1});
    velXGrid = vel{1,1};
    velYGrid = vel{2,1};
end
