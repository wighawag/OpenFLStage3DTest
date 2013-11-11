package;


import flash.display.Sprite;
import flash.display.Stage;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;

import flash.display3D.Context3D;
import flash.display.Stage3D;
import flash.display3D.shaders.glsl.GLSLProgram;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.Context3DVertexBufferFormat;

import flash.display3D.textures.Texture;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DTextureFilter;
import flash.display3D.Context3DWrapMode;


import flash.display3D.shaders.glsl.GLSLFragmentShader;
import flash.display3D.shaders.glsl.GLSLVertexShader;

using OpenFLStage3D;

import flash.events.Event;
import flash.events.ErrorEvent;

class Main extends Sprite {

    public static function myTrace(message : Dynamic, ?posInfos : haxe.PosInfos) : Void
    {
        #if flash
            flash.Lib.trace(message);
        #elseif js
             untyped console.log(message);
        #else
            untyped __trace(message, posInfos);
        #end

    }

    private var stage3D : Stage3D;
    private var context3D : Context3D;
    private var sceneProgram : GLSLProgram;

    private var vertexBuffer : VertexBuffer3D;
    private var indexBuffer : IndexBuffer3D;

    private var texture : Texture;

	public function new () {
        super ();

        haxe.Log.trace = myTrace;

        stage3D = stage.getStage3D(0);
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onReady);
        stage3D.addEventListener(ErrorEvent.ERROR, onError);
        stage3D.requestContext3D();
		
		
		//stage3D.x = 30;
		//stage3D.y = 30;


    }

	private function onError(event : ErrorEvent):Void{
	    trace(event);
    }

    private function onReady(event : Event) : Void{
        context3D = stage3D.context3D;
        context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
        context3D.enableErrorChecking = true;

        #if html5
        var vertexShaderSource =
			"precision mediump int;
			precision mediump float;
			attribute vec3 vertexPosition;
		    attribute vec2 uv;
			uniform mat4 modelViewMatrix;
			uniform mat4 projectionMatrix;
			//uniform mat4 matrix;
			varying vec2 vTexCoord;
			void main(void) {
				gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
				//gl_Position = matrix * vec4(vertexPosition, 1.0);
				vTexCoord = uv;
			}";
        #else
        var vertexShaderSource =
        "attribute vec3 vertexPosition;
		    attribute vec2 uv;
			uniform mat4 modelViewMatrix;
			uniform mat4 projectionMatrix;
			//uniform mat4 matrix;
			varying vec2 vTexCoord;
			void main(void) {
				gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
				//gl_Position = matrix * vec4(vertexPosition, 1.0);
				vTexCoord = uv;
			}";

        #end


        //var vertexAgalInfo = '{"varnames":{"uv":"va1","matrix":"vc0","vertexPosition":"va0"},"agalasm":"m44 op, va0, vc0\\nmov v0, va1","storage":{},"types":{},"info":"","consts":{}}';
        var vertexAgalInfo = '{"varnames":{"uv":"va1","modelViewMatrix":"vc0","projectionMatrix":"vc4","vertexPosition":"va0"},"agalasm":"m44 vt0, va0, vc0\\nm44 op, vt0, vc4\\nmov v0, va1","storage":{},"types":{},"info":"","consts":{}}';

        #if html5
		var fragmentShaderSource =
			"precision mediump int;
			precision mediump float;
			varying vec2 vTexCoord;
			 uniform sampler2D texture;
		     void main(void) {
		        vec4 texColor = texture2D(texture, vTexCoord);
				gl_FragColor = texColor;
			}";
        #else
        var fragmentShaderSource =
        "varying vec2 vTexCoord;
			 uniform sampler2D texture;
		     void main(void) {
		        vec4 texColor = texture2D(texture, vTexCoord);
				gl_FragColor = texColor;
			}";
        #end


        var fragmentAgalInfo = '{"varnames":{"texture":"fs0"},"agalasm":"mov ft0, v0\\ntex ft1, ft0, fs0 <2d,wrap,linear>\\nmov oc, ft1","storage":{},"types":{},"info":"","consts":{}}';

        var vertexShader = new GLSLVertexShader(vertexShaderSource,vertexAgalInfo);
        var fragmentShader = new GLSLFragmentShader(fragmentShaderSource,fragmentAgalInfo);

        sceneProgram = new GLSLProgram(context3D);
        sceneProgram.upload(vertexShader, fragmentShader);

        var logo = openfl.Assets.getBitmapData("assets/hxlogo.png");
        texture = context3D.createTexture(logo.width,logo.height, Context3DTextureFormat.BGRA,false);
        texture.uploadFromBitmapData(logo);

        var vertices : Array<Float> = [
            -100,   -100,   0,     0,   0,
            100,  -100,   0,     1,   0,
            -100,   100,  0,     0,   1,
            100,  100,  0,     1,   1
        ];

        vertexBuffer = context3D.createVertexBuffer(4,5);
        vertexBuffer.uploadFromVector(flash.Vector.ofArray(vertices), 0, 4);

        indexBuffer = context3D.createIndexBuffer(6);
        var indexes : Array<UInt> = [0,1,2,1,2,3];
        indexBuffer.uploadFromVector(flash.Vector.ofArray(indexes), 0, 6);

        context3D.setBlendFactors(flash.display3D.Context3DBlendFactor.SOURCE_ALPHA, flash.display3D.Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        context3D.setRenderCallback(renderView);
		
		//context3D.setScissorRectangle(new Rectangle(30,30,100,100));
    }

	private function renderView (event : Event):Void {
        context3D.clear(0, 0.5, 0, 0);

		
		var positionX = stage.stageWidth / 2;
		var positionY = stage.stageHeight / 2;
		var projectionMatrix = Matrix3DUtils.createOrtho (0, stage.stageWidth, stage.stageHeight, 0, 1000, -1000);
		var modelViewMatrix = Matrix3DUtils.create2D (positionX, positionY, 1, 0);

        //var matrix = modelViewMatrix;
        //matrix.append(projectionMatrix);

        sceneProgram.attach();
        sceneProgram.setVertexBufferAt("vertexPosition",vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
        sceneProgram.setVertexBufferAt("uv",vertexBuffer,3,Context3DVertexBufferFormat.FLOAT_2);
        sceneProgram.setTextureAt("texture",texture);
        sceneProgram.setVertexUniformFromMatrix("projectionMatrix",projectionMatrix,true);
        sceneProgram.setVertexUniformFromMatrix("modelViewMatrix",modelViewMatrix,true);
        //sceneProgram.setVertexUniformFromMatrix("matrix",matrix, true);
        //sceneProgram.setSamplerStateAt("texture",Context3DWrapMode.CLAMP,Context3DTextureFilter.LINEAR,Context3DMipFilter.MIPNONE);

        context3D.drawTriangles(indexBuffer);
        context3D.present();
	}

}
