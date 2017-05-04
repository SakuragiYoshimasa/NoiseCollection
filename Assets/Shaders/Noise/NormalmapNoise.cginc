vec3 normalNoise(vec2 _st, float _zoom, float _speed){
	vec2 v1 = _st;
	vec2 v2 = _st;
	vec2 v3 = _st;
	float expon = pow(10.0, _zoom*2.0);
	v1 /= 1.0*expon;
	v2 /= 0.62*expon;
	v3 /= 0.83*expon;
	float n = time*_speed;
	float nr = (simplexNoise(vec3(v1, n)) + simplexNoise(vec3(v2, n)) + simplexNoise(vec3(v3, n))) / 6.0 + 0.5;
	n = time * _speed + 1000.0;
	float ng = (simplexNoise(vec3(v1, n)) + simplexNoise(vec3(v2, n)) + simplexNoise(vec3(v3, n))) / 6.0 + 0.5;
	return vec3(nr,ng,0.5);
}