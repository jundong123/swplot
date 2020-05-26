/* Put sfr on q3 grid
   d_cal_s3(loni, lati, sfr, sfr1, ns, s0, ds);

   Jun Dong, 08/11/2015
*/

#include "stdio.h"
#include "stdlib.h"
#include "math.h"
//#include "idl_export.h"


int cal_s3(int nfov, int nsl, float **loni, float **lati, float **sfr,
		int *ns, float *s0, float *ds, float **sfr1);


/********************/
/* idl interface */
/********************/
void i_cal_s3(int argc, void *argv[])
{
	int    nfov, nsl;
	float  **loni, **lati, **sfr;
	int    ns[2];
	float  s0[2], ds[2];
	float  *result = argv[8];

	int    i, j;
	int    *pini;
	float  *pinf;
	float  **sfr1;

	if (argc != 9)  {
		printf("Error: Wrong number of input.\n");
		return;
	}

	/* inputs  */
	nfov = *((int *)argv[0]);
	nsl = *((int *)argv[1]);
	/*printf("%d %d\n", nsl, nfov);*/

	pinf = (float *)argv[2];
	loni = (float **) malloc((nsl+1) * sizeof(float *));
	for (j=0; j<nsl+1; j++)  {
		loni[j] = (float *) malloc((nfov+1) * sizeof(float));
		for (i=0; i<nfov+1; i++)  {
			loni[j][i] = pinf[i*(nsl+1)+j];
			/*printf((i!=nfov?"%5.2f ":"%5.2f\n"), loni[j][i]);*/
		}
	}

	pinf = (float *)argv[3];
	lati = (float **) malloc((nsl+1) * sizeof(float *));
	for (j=0; j<nsl+1; j++)  {
		lati[j] = (float *) malloc((nfov+1) * sizeof(float));
		for (i=0; i<nfov+1; i++)  {
			lati[j][i] = pinf[i*(nsl+1)+j];
			/*printf((i!=nfov?"%5.2f ":"%5.2f\n"), lati[j][i]);*/
		}
	}

	pinf = (float *)argv[4];
	sfr = (float **) malloc(nsl * sizeof(float *));
	for (j=0; j<nsl; j++)  {
		sfr[j] = (float *) malloc(nfov * sizeof(float));
		for (i=0; i<nfov; i++)  {
			sfr[j][i] = pinf[i*nsl+j];
			/*printf((i!=nfov-1?"%5.2f ":"%5.2f\n"), sfr[j][i]);*/
		}
	}

	pini = (int *)argv[5];
	ns[0] = pini[0];    ns[1] = pini[1];
	/*printf("%d %d\n", ns[0], ns[1]);*/

	pinf = (float *)argv[6];
	s0[0] = pinf[0];    s0[1] = pinf[1];
	/*printf("%5.2f %5.2f\n", s0[0], s0[1]);*/

	pinf = (float *)argv[7];
	ds[0] = pinf[0];    ds[1] = pinf[1];
	/*printf("%5.2f %5.2f\n", ds[0], ds[1]);*/


	/* output  */
	pinf = (float *)argv[8];
	sfr1 = (float **) malloc(ns[0] * sizeof(float *));
	for (i=0; i<ns[0]; i++)
		sfr1[i] = (float *) malloc(ns[1] * sizeof(float));
	/* initialize  */
	for (j=0; j<ns[1]; j++)  {
		for (i=0; i<ns[0]; i++)  {
			sfr1[i][j] = pinf[j*ns[1]+i];
			/*printf((i!=ns[0]-1?"%5.2f ":"%5.2f\n"), sfr1[i][j]);*/
		}
	}

	/* calculation  */
	cal_s3(nfov, nsl, loni, lati, sfr, ns, s0, ds, sfr1);

	/* assign  */
	for (j=0; j<ns[1]; j++)  {
		for (i=0; i<ns[0]; i++)
			*result++ = sfr1[i][j];
	}

	return;
}


/* original c-functions called  */
int cal_s3(int nfov, int nsl, float **loni, float **lati, float **sfr,
		int *ns, float *s0, float *ds, float **sfr1)
{
	int   i0, i1, i2, i3;
	int   i4, i5, in;
	float tt;
	float lon00, lon01, lon10, lon11, lat00, lat01, lat10, lat11;
	float lonb0, lonb1, latb0, latb1;
	float lonv[4], latv[4], lonb2,latb2;
	int   ilonb0, ilonb1, ilatb0, ilatb1;

	/*
	printf("in cal_s3\n");;
	printf("nlon=%d nlat=%d\n", ns[0], ns[1]);
	printf("lon0=%f lat0=%f\n", s0[0], s0[1]);
	printf("dlon=%f dlat=%f\n", ds[0], ds[1]);
	printf("nsl=%d nfov=%d\n", nsl, nfov);
	*/

	for (i0=0; i0<nsl; i0++)  {
		/*printf("%d ", i0);*/
		for (i1=0; i1<nfov; i1++)  {
		/*printf("\n\n%d %d\n", i0, i1);*/

			/* unwrap 4 points  */
			lon00 = loni[i0][i1];    lon01 = loni[i0][i1+1];
			lon10 = loni[i0+1][i1];  lon11 = loni[i0+1][i1+1];
			tt = lon01 -lon00;
			if (tt < -180)
				lon01 = lon01 + 360;
			else if (tt > 180)
				lon01 = lon01 - 360;
			tt = lon10 -lon00;
			if (tt < -180)
				lon10 = lon10 + 360;
			else if (tt > 180)
				lon10 = lon10 - 360;
			tt = lon11 -lon00;
			if (tt < -180)
				lon11 = lon11 + 360;
			else if (tt > 180)
				lon11 = lon11 - 360;
			lat00 = lati[i0][i1];    lat01 = lati[i0][i1+1];
			lat10 = lati[i0+1][i1];  lat11 = lati[i0+1][i1+1];

			/*
			printf("\nlon00, lon01, lon10, lon11\n");
			printf("%5.2f %5.2f %5.2f %5.2f\n",
					lon00, lon01, lon10, lon11);
			printf("\nlat00, lat01, lat10, lat11\n");
			printf("%5.2f %5.2f %5.2f %5.2f\n",
					lat00, lat01, lat10, lat11);
			*/

			/* lonb, latb  */
			lonb0 = (lon00 < lon01 ? lon00 : lon01);
			lonb0 = (lonb0 < lon10 ? lonb0 : lon10);
			lonb0 = (lonb0 < lon11 ? lonb0 : lon11);

			lonb1 = (lon00 > lon01 ? lon00 : lon01);
			lonb1 = (lonb1 > lon10 ? lonb1 : lon10);
			lonb1 = (lonb1 > lon11 ? lonb1 : lon11);

			latb0 = (lat00 < lat01 ? lat00 : lat01);
			latb0 = (latb0 < lat10 ? latb0 : lat10);
			latb0 = (latb0 < lat11 ? latb0 : lat11);

			latb1 = (lat00 > lat01 ? lat00 : lat01);
			latb1 = (latb1 > lat10 ? latb1 : lat10);
			latb1 = (latb1 > lat11 ? latb1 : lat11);

			ilonb0 = floor((lonb0 - s0[0]) / ds[0]);
			ilonb1 = ceil ((lonb1 - s0[0]) / ds[0]);

			ilatb0 = floor((latb0 - s0[1]) / ds[1]);
			ilatb1 = ceil ((latb1 - s0[1]) / ds[1]);

			/*
			printf("\nlonb0, lonb1, latb0, latb1\n");
			printf("%5.2f %5.2f %5.2f %5.2f\n",
					lonb0, lonb1, latb0, latb1);
			printf("\nilonb0, ilonb1, ilatb0, ilatb1\n");
			printf("%5d %5d %5d %5d\n",
					ilonb0, ilonb1, ilatb0, ilatb1);
			*/

			if (ilonb0 < 0)          ilonb0 = 0;
			if (ilonb1 > ns[0]-1)    ilonb1 = ns[0] - 1;

			if (ilatb0 < 0)          ilatb0 = 0;
			if (ilatb1 > ns[1]-1)    ilatb1 = ns[1] - 1;
			
			/*
			printf("\nilonb0, ilonb1, ilatb0, ilatb1\n");
			printf("%5d %5d %5d %5d\n",
					ilonb0, ilonb1, ilatb0, ilatb1);
			*/

			if (ilonb0 > ilonb1 || ilatb0 > ilatb1)
				continue;

			/* inside */
			lonv[0] = lon00;  lonv[1] = lon01;
			lonv[2] = lon11;  lonv[3] = lon10;

			latv[0] = lat00;  latv[1] = lat01;
			latv[2] = lat11;  latv[3] = lat10;

			/*
			printf("\nlonv[0], lonv[1], lonv[2], lonv[3]\n");
			printf("%5.2f %5.2f %5.2f %5.2f\n",
					lonv[0], lonv[1], lonv[2], lonv[3]);
			printf("\nlatv[0], latv[1], latv[2], latv[3]\n");
			printf("%5.2f %5.2f %5.2f %5.2f\n\n",
					latv[0], latv[1], latv[2], latv[3]);
			*/

			for (i2=ilonb0; i2<=ilonb1; i2++)  {
				lonb2 = s0[0] + i2 * ds[0];
				for (i3=ilatb0; i3<=ilatb1; i3++)  {
					latb2 = s0[1] + i3 * ds[1];
					/* check inside  */
					in = 0;
					for (i4=0, i5=3; i4<4; i5=i4++)  {
						if ( ((latv[i4]>latb2) != (latv[i5]>latb2))
								&& (lonb2 < (lonv[i5]-lonv[i4])
								*(latb2-latv[i4])
								/(latv[i5]-latv[i4])+lonv[i4]) )
							in = !in;
					}
					/*
					printf("\n%5d %5d %5.2f %5.2f %5d\n",
							i2, i3, lonb2, latb2, in);
					*/
					if (in == 1)
						sfr1[i2][i3] = sfr[i0][i1];
				}
				/*
   				int i4, i5;
				for (i4=0; i4<ns[1]; i4++)  {
					for (i5=0; i5<ns[0]; i5++)
						printf("%5.2f ", sfr1[i5][i4]);
					printf("\n");
				}
				*/
			}

		}
	}

	return(0);
}



