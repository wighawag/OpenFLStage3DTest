package;

import flash.geom.Matrix3D;
import flash.Vector;

class Matrix3DUtils{

    public static function create2D (x:Float, y:Float, scale:Float = 1, rotation:Float = 0):Matrix3D {

        var theta = rotation * Math.PI / 180.0;
        var c = Math.cos (theta);
        var s = Math.sin (theta);

        var values = new Vector<Float>(16);
        values[0] = c * scale;  values[1]=-s * scale; values[2]=0;  values[3]=0;
        values[4] = s * scale;  values[5]=c * scale;  values[6]=0;  values[7]=0;
        values[8] = 0;          values[9]=0;          values[10]=1; values[11]=0;
        values[12] = x;         values[13]=y;         values[14]=0; values[15]=1;
        return new Matrix3D (values);

    }

    public static function createOrtho (x0:Float, x1:Float,  y0:Float, y1:Float, zNear:Float, zFar:Float):Matrix3D {

        var sx = 1.0 / (x1 - x0);
        var sy = 1.0 / (y1 - y0);
        var sz = 1.0 / (zFar - zNear);

        var values = new Vector<Float>(16);
        values[0] = 2.0 * sx;           values[1]=0;                values[2]=0;                     values[3]=0;
        values[4] = 0;                  values[5]=2.0 * sy;         values[6]=0;                     values[7]=0;
        values[8] = 0;                  values[9]=0;                values[10]=-2.0*sz;              values[11]=0;
        values[12] = -(x0 + x1) * sx;   values[13]=-(y0 + y1) * sy; values[14]=-(zNear + zFar) * sz; values[15]=1;
        return new Matrix3D (values);

    }



}