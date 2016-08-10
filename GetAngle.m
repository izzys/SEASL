function  angle  = GetAngle( u,v )


angle =  wrapTo360(  acos(u*v'/norm(u)/norm(v))*180/pi );

end

