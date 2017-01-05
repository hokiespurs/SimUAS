function fov = calcfov(sensorsize,f)

fov = 2 * atand(sensorsize/2/f);

end