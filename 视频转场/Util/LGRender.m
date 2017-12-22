//
//  LGRender.m
//  VideoBlend
//
//  Created by L了个G on 2017/12/20.
//  Copyright © 2017年 L了个G. All rights reserved.
//

#import "LGRender.h"
#import <GLKit/GLKit.h>
enum
{
    UNIFORM_FROM,
    UNIFORM_FROMFILTER1,
    UNIFORM_FROMFILTER2,
    UNIFORM_FROMFILTETYPE,
    UNIFORM_ALPHA,
    UNIFORM_TO,
    UNIFORM_TOFILTER1,
    UNIFORM_TOFILTER2,
    UNIFORM_TOFILTERTYPE,
    UNIFORM_PROGRESS,
    UNIFORM_ROTATION_ANGLE,//旋转矩阵
    UNIFORM_COLOR_CONVERSION_MATRIX,// 色彩转换矩阵
    UNIFORM_TYPE,
    UNIFORM_SQUARESIZE,
    NUM_UNIFORMS
};
GLint unforms[NUM_UNIFORMS];

enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBURTES
};
@interface LGRender()
@property CGAffineTransform renderTransform;
@property CVOpenGLESTextureCacheRef videoTextureCache;
@property EAGLContext *currentContext;
@property GLuint offscreenBufferHandle;
@property GLuint program;
@property BOOL isFirst;
@end

@implementation LGRender
+ (instancetype)sharedRender {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
    });
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _currentContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_currentContext];
        [self setupOffscreenRenderContext];
        NSURL *vertexURL = [[NSBundle mainBundle] URLForResource:@"TransitionVertex" withExtension:@"glsl"];
        NSURL *fragURL = [[NSBundle mainBundle] URLForResource:@"TransitionFrag" withExtension:@"glsl"];
        [self loadVertexShader:vertexURL AndFragShader:fragURL];
        self.isFirst = YES;
    }
    
    return self;
}

- (void)setupOffscreenRenderContext
{
    //-- Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = NULL;
    }
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _currentContext, NULL, &_videoTextureCache);
    if (err != noErr) {
        NSLog(@"Transiton Error at CVOpenGLESTextureCacheCreate %d", err);
    }
    
    glDisable(GL_DEPTH_TEST);
    
    glGenFramebuffers(1, &_offscreenBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
}
-(BOOL)loadVertexShader:(NSURL *)vertexURL AndFragShader:(NSURL *)fragURL{
    GLuint vertShader,fragShader;
    _program = glCreateProgram();
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER URL:vertexURL]) {
        NSLog(@"Transiton Failed to compile vertex shader");
        return NO;
    }
    
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER URL:fragURL]) {
        NSLog(@"Transiton Failed to compile frag shader");
        return NO;
    }
    
    glAttachShader(_program, vertShader);
    
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_TEXCOORD, "texCoord");
    
    if (![self linkProgram:_program]) {
        NSLog(@"Transiton Faided to link program:%d",_program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    unforms[UNIFORM_FROM] = glGetUniformLocation(_program, "from");
    unforms[UNIFORM_TO] = glGetUniformLocation(_program, "to");
    unforms[UNIFORM_ROTATION_ANGLE] = glGetUniformLocation(_program, "preferredRotation");
    unforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(_program, "colorConversionMatrix");
    unforms[UNIFORM_TYPE] = glGetUniformLocation(_program, "type");
    unforms[UNIFORM_ALPHA] = glGetUniformLocation(_program, "alpha");
    unforms[UNIFORM_PROGRESS] = glGetUniformLocation(_program, "progress");
    unforms[UNIFORM_FROMFILTETYPE] = glGetUniformLocation(_program, "fromFilterType");
    unforms[UNIFORM_FROMFILTER1] = glGetUniformLocation(_program, "fromFilter1");
    unforms[UNIFORM_FROMFILTER2] = glGetUniformLocation(_program, "fromFilter2");
    unforms[UNIFORM_TOFILTERTYPE] = glGetUniformLocation(_program, "toFilterType");
    unforms[UNIFORM_TOFILTER1] = glGetUniformLocation(_program, "toFilter1");
    unforms[UNIFORM_TOFILTER2] = glGetUniformLocation(_program, "toFilter2");
    unforms[UNIFORM_SQUARESIZE] = glGetUniformLocation(_program, "squareSizeFactor");
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL
{
    NSError *error;
    NSString *sourceString = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        NSLog(@"Transiton Failed to load shader : %@",[error localizedDescription]);
        return NO;
    }
    GLint status;
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Transiton Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Transiton Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)renderPixelBuffer:(CVPixelBufferRef)destinationPixelBuffer usingForegroundSourceBuffer:(CVPixelBufferRef)foregroundPixelBuffer andBackgroundSourceBuffer:(CVPixelBufferRef)backgroundPixelBuffer forTweenFactor:(float)tween type:(TransitionType)type
{
    [EAGLContext setCurrentContext:self.currentContext];
    
    if (foregroundPixelBuffer || backgroundPixelBuffer) {
        
        CVOpenGLESTextureRef foregroundTexture = [self sourceTextureForPixelBuffer:foregroundPixelBuffer];
        CVOpenGLESTextureRef backgroundTexture = [self sourceTextureForPixelBuffer:backgroundPixelBuffer];
        CVOpenGLESTextureRef destTexture       = [self sourceTextureForPixelBuffer:destinationPixelBuffer];
        glViewport(0, 0, 540, 960);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(CVOpenGLESTextureGetTarget(foregroundTexture), CVOpenGLESTextureGetName(foregroundTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(CVOpenGLESTextureGetTarget(backgroundTexture), CVOpenGLESTextureGetName(backgroundTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture), 0);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Transiton Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glUseProgram(_program);
        GLfloat quadVertexData1 [] = {
            -1.0, 1.0,
            1.0, 1.0,
            -1.0, -1.0,
            1.0, -1.0,
        };
        
        // texture data varies from 0 -> 1, whereas vertex data varies from -1 -> 1
        GLfloat quadTextureData1 [] = {
            0.5 + quadVertexData1[0]/2, 0.5 + quadVertexData1[1]/2,
            0.5 + quadVertexData1[2]/2, 0.5 + quadVertexData1[3]/2,
            0.5 + quadVertexData1[4]/2, 0.5 + quadVertexData1[5]/2,
            0.5 + quadVertexData1[6]/2, 0.5 + quadVertexData1[7]/2,
        };
        if (type == RenderTransisionTypePixelize) {
            glUniform1f(unforms[UNIFORM_SQUARESIZE],100.0);
        }
        
        NSLog(@"type --- %d,tewwn ----%f",type,tween);
        glUniform1i(unforms[UNIFORM_FROM], 0);
        glUniform1i(unforms[UNIFORM_TO], 1);
        glUniform1f(unforms[UNIFORM_ALPHA],1.0 - tween);
        glUniform1i(unforms[UNIFORM_TYPE], type);
        glUniform1f(unforms[UNIFORM_PROGRESS], tween);
        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, quadVertexData1);
        glEnableVertexAttribArray(ATTRIB_VERTEX);
        glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, 0, 0, quadTextureData1);
        glEnableVertexAttribArray(ATTRIB_TEXCOORD);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glFlush();
    bail:
        if (foregroundTexture) {
            CFRelease(foregroundTexture);
        }
        
        if (backgroundTexture) {
            CFRelease(backgroundTexture);
        }
        
        CFRelease(destTexture);
        // Periodic texture cache flush every frame
        CVOpenGLESTextureCacheFlush(self.videoTextureCache, 0);
        [EAGLContext setCurrentContext:nil];
        
    }
    
}
-(CVOpenGLESTextureRef)sourceTextureForPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVOpenGLESTextureRef sourceTexture = NULL;
    CVReturn err;
    if (!_videoTextureCache) {
        NSLog(@"Transiton No video texture cache");
        goto bail;
    }
    
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, (int)CVPixelBufferGetWidth(pixelBuffer), (int)CVPixelBufferGetHeight(pixelBuffer), GL_RGBA, GL_UNSIGNED_BYTE, 0, &sourceTexture);
    if (err) {
        NSLog(@"Transiton Error at creating luma texture using CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
bail:
    return sourceTexture;
}
- (void)dealloc
{
    NSLog(@"render dealloc ========================================");
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
    if (_offscreenBufferHandle) {
        glDeleteFramebuffers(1, &_offscreenBufferHandle);
        _offscreenBufferHandle = 0;
    }
}

@end
