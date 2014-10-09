imshow(img_color);

hold on;
numStr = sprintf('#%04d', f);
text(10,20,numStr,'Color','r', 'FontWeight','bold', 'FontSize', 20);
hold off;

color = [ 0 1 0 ];
drawbox([32 32], result(f,:), 'Color', color, 'LineWidth', 2.5);
drawnow;