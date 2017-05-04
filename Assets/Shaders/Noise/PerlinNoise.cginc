#define M_PI 3.14159265358979323846

float rand(float2 c){
	return fract(sin(dot(c.xy ,float2(12.9898,78.233))) * 43758.5453);
}

float noise(float2 p, float freq ){
	float unit = screenWidth/freq;
	float2 ij = floor(p/unit);
	float2 xy = mod(p,unit)/unit;
	//xy = 3.*xy*xy-2.*xy*xy*xy;
	xy = .5*(1.-cos(PI*xy));
	float a = rand((ij+float2(0.,0.)));
	float b = rand((ij+float2(1.,0.)));
	float c = rand((ij+float2(0.,1.)));
	float d = rand((ij+float2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(float2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<50; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}