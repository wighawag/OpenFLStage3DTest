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

import flash.display3D.shaders.glsl.GLSLFragmentShader;
import flash.display3D.shaders.glsl.GLSLVertexShader;

using flash.display3D.Context3DUtils;

import flash.events.Event;
import flash.events.ErrorEvent;

class Main extends Sprite {

    private var stage3D : Stage3D;
    private var context3D : Context3D;
    private var sceneProgram : GLSLProgram;

    private var vertexBuffer : VertexBuffer3D;
    private var indexBuffer : IndexBuffer3D;

//	private var shaderProgram:GLProgram;
//	private var vertexAttribute:Int;
//	private var vertexBuffer:GLBuffer;
//	private var view:OpenGLView;

	public function new () {
        super ();
        stage3D = stage.stage3Ds[0];
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onReady);
        stage3D.addEventListener(ErrorEvent.ERROR, onError);
        stage3D.requestContext3D();

       	}

	private function onError(event : ErrorEvent):Void{
	    trace(event);
    }

    private function onReady(event : Event) : Void{
        context3D = stage3D.context3D;
        context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
        context3D.enableErrorChecking = true;

        var vertexShaderSource =
			"attribute vec3 vertexPosition;
			uniform mat4 modelViewMatrix;
			uniform mat4 projectionMatrix;
			void main(void) {
				gl_Position = projectionMatrix * modelViewMatrix * vec4(vertexPosition, 1.0);
			}";

		var fragmentShaderSource =
			"void main(void) {
				gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
			}";

        var vertexShader = new GLSLVertexShader(vertexShaderSource);
        var fragmentShader = new GLSLFragmentShader(fragmentShaderSource);

        sceneProgram = new GLSLProgram(context3D);
        sceneProgram.upload(vertexShader, fragmentShader);


        var vertices = [
            100, 100, 0,
            -100, 100, 0,
            100, -100, 0,
            -100, -100, 0
        ];
        vertexBuffer = context3D.createVertexBuffer(4,3);
        vertexBuffer.uploadFromVector(vertices, 0, 4);

        indexBuffer = context3D.createIndexBuffer(6);
        indexBuffer.uploadFromVector([0,1,2,1,2,3], 0, 6);

        context3D.setRenderCallback(renderView);
    }

	private function renderView (event : Event):Void {
        context3D.clear(8 >> 8, 146 >> 8, 208 >> 8, 1);

		var positionX = stage.stageWidth / 2;
		var positionY = stage.stageHeight / 2;
		var projectionMatrix = Matrix3D.createOrtho (0, stage.stageWidth, stage.stageHeight, 0, 1000, -1000);
		var modelViewMatrix = Matrix3D.create2D (positionX, positionY, 1, 0);

        sceneProgram.attach();
        sceneProgram.setVertexBufferAt("vertexPosition",vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
        sceneProgram.setVertexUniformFromMatrix("projectionMatrix",projectionMatrix,true);
        sceneProgram.setVertexUniformFromMatrix("modelViewMatrix",modelViewMatrix,true);

        context3D.drawTriangles(indexBuffer);
	}

}
