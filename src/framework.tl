import "tlang/std.tl"
import "tlang/opengl.tl"
import "tlang/string.tl"
import "src/main.tl"

default_debug_proc :: (source: GLenum, typ: GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: *GLchar, userParam: *Void) {
	// ignore non-significant error/warning codes
	//if(id == 131169 || id == 131185 || id == 131218 || id == 131204)
	//	return

	print("==== Debug Message ====\nID: {}\n", id)
	print("Source: "); println(String(@message, strlen(message)))
	     if source == GL_DEBUG_SOURCE_API             print("API")
	else if source == GL_DEBUG_SOURCE_WINDOW_SYSTEM   print("Window System")
	else if source == GL_DEBUG_SOURCE_SHADER_COMPILER print("Shader Compiler")
	else if source == GL_DEBUG_SOURCE_THIRD_PARTY     print("Third Party")
	else if source == GL_DEBUG_SOURCE_APPLICATION     print("Application")
	else if source == GL_DEBUG_SOURCE_OTHER           print("Other")
	print("\nType: ")
	     if typ == GL_DEBUG_TYPE_ERROR               print("Error")
	else if typ == GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR print("Deprecated Behaviour")
	else if typ == GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR  print("Undefined Behaviour")
	else if typ == GL_DEBUG_TYPE_PORTABILITY         print("Portability")
	else if typ == GL_DEBUG_TYPE_PERFORMANCE         print("Performance")
	else if typ == GL_DEBUG_TYPE_MARKER              print("Marker")
	else if typ == GL_DEBUG_TYPE_PUSH_GROUP          print("Push Group")
	else if typ == GL_DEBUG_TYPE_POP_GROUP           print("Pop Group")
	else if typ == GL_DEBUG_TYPE_OTHER               print("Other")
	print("\nSeverity: ")

	     if severity == GL_DEBUG_SEVERITY_HIGH         print("high")
	else if severity == GL_DEBUG_SEVERITY_MEDIUM       print("medium")
	else if severity == GL_DEBUG_SEVERITY_LOW          print("low")
	else if severity == GL_DEBUG_SEVERITY_NOTIFICATION print("notification")
	print("\n")
}

compile_shader :: (shader: GLuint): GLuint {
	glCompileShader(shader)

	status: GLint
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status)

	if status == 0 {
		maxLength: GLint
		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &maxLength)

		message := VirtualAlloc(null, @maxLength, MEM_RESERVE|MEM_COMMIT, PAGE_READWRITE)
		glGetShaderInfoLog(shader, maxLength, &maxLength, @message)

		glDeleteShader(shader)

		print(String(@message, @maxLength))
		return 0
	}
	return shader
}

create_shader :: (shaderType: GLenum, source: String): GLuint {
	shader := glCreateShader(shaderType)
	glShaderSource(shader, 1, &source.data, @&source.count)
	return compile_shader(shader)
}

ProgramStages :: struct {
	vertex:   GLuint
	fragment: GLuint
	compute:  GLuint
}

create_program :: (stages: ProgramStages): GLuint {
	result := glCreateProgram()
	if stages.vertex   != 0  glAttachShader(result, stages.vertex)
	if stages.fragment != 0  glAttachShader(result, stages.fragment)
	if stages.compute  != 0  glAttachShader(result, stages.compute)
	glLinkProgram(result)
	if stages.vertex   != 0  glDetachShader(result, stages.vertex)
	if stages.fragment != 0  glDetachShader(result, stages.fragment)
	if stages.compute  != 0  glDetachShader(result, stages.compute)

	status: GLint
	glGetProgramiv(result, GL_LINK_STATUS, &status)

	if status == 0 {
		maxLength: GLint
		glGetProgramiv(result, GL_INFO_LOG_LENGTH, &maxLength)

		message := VirtualAlloc(null, @maxLength, MEM_RESERVE|MEM_COMMIT, PAGE_READWRITE)
		glGetProgramInfoLog(result, maxLength, &maxLength, @message)

		glDeleteProgram(result)
		result = 0

		print(String(@message, @maxLength))
	}
	return result
}

dc: HDC

window_size: V2s

V4f :: struct {
	x: F32
	y: F32
	z: F32
	w: F32
}

data :: (me: *V4f) => &x
span :: (me: *V4f) => ([]F32)(me.data(), 4)

operator + :: (a: V4f, b: V4f) => V4f(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
operator - :: (a: V4f, b: V4f) => V4f(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
operator * :: (a: V4f, b: V4f) => V4f(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
operator / :: (a: V4f, b: V4f) => V4f(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w)


V2s :: struct {
	x: S32
	y: S32
}

v2s :: (v: S32) => V2s(v, v)

data :: (me: *V2s) => &x
span :: (me: *V2s) => ([]S32)(me.data(), 2)

operator + :: (a: V2s, b: V2s) => V2s(a.x + b.x, a.y + b.y)
operator - :: (a: V2s, b: V2s) => V2s(a.x - b.x, a.y - b.y)
operator * :: (a: V2s, b: V2s) => V2s(a.x * b.x, a.y * b.y)
operator / :: (a: V2s, b: V2s) => V2s(a.x / b.x, a.y / b.y)
operator + :: (a: V2s, b: S32) => V2s(a.x + b, a.y + b)
operator - :: (a: V2s, b: S32) => V2s(a.x - b, a.y - b)
operator * :: (a: V2s, b: S32) => V2s(a.x * b, a.y * b)
operator / :: (a: V2s, b: S32) => V2s(a.x / b, a.y / b)
operator as :: (a: V2s) => V2f(@a.x, @a.y)

V2f :: struct {
	x: F32
	y: F32
}

data :: (me: *V2f) => &x
span :: (me: *V2f) => ([]F32)(me.data(), 2)

operator + :: (a: V2f, b: V2f) => V2f(a.x + b.x, a.y + b.y)
operator - :: (a: V2f, b: V2f) => V2f(a.x - b.x, a.y - b.y)
operator * :: (a: V2f, b: V2f) => V2f(a.x * b.x, a.y * b.y)
operator / :: (a: V2f, b: V2f) => V2f(a.x / b.x, a.y / b.y)
operator + :: (a: V2f, b: F32) => V2f(a.x + b, a.y + b)
operator - :: (a: V2f, b: F32) => V2f(a.x - b, a.y - b)
operator * :: (a: V2f, b: F32) => V2f(a.x * b, a.y * b)
operator / :: (a: V2f, b: F32) => V2f(a.x / b, a.y / b)
operator as :: (a: V2f) => V2s(@a.x, @a.y)

length :: (me: V2f) => sqrt(x*x + y*y)
normalized :: (me: V2f) {
	f := 1.0 / me.length()
	return V2f(x * f, y * f)
}

Rect :: struct {
	min: V2s
	max: V2s
}

rect :: (minx: S32, miny: S32, maxx: S32, maxy: S32) => Rect(V2s(minx, miny), V2s(maxx, maxy))
rect :: (min: V2s, max: V2s) => Rect(min, max)
rect :: (min: V2s, size: V2s) => Rect(min, min+size)

size :: (me: *Rect) => me.max - me.min

extend :: (me: *Rect, extent: V2s) => Rect(min - extent, max + extent)

in_bounds :: (me: V2s, rect: Rect) =>
    rect.min.x <= me.x && me.x < rect.max.x &&
    rect.min.y <= me.y && me.y < rect.max.y;


XorShift32 :: struct {
	// TODO: default values
	// v: U32 = 1
	v: U32
};

next :: (me: *XorShift32) {
	/* Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs" */
	v ^= v << 13
	v ^= v >> 17
	v ^= v << 5
	return v
}

random_F32 :: (me: *XorShift32) {
	return (me.next() >> 8) as S32 as F32 * (1.0 / 16777216.0)
}

random_in_circle :: (me: *XorShift32) {
	result: V2f
	while true {
		result.x = me.random_F32() * 2 - 1
		result.y = me.random_F32() * 2 - 1
		if result.length() <= 1.0
			break
	}
	return result
}

random_unit :: (me: *XorShift32) => me.random_in_circle().normalized()

program: GLuint

draw_rect :: (rect: Rect) {
	size := rect.size()
	glViewport(rect.min.x, rect.min.y, size.x, size.y)
	glDrawArrays(GL_TRIANGLES, 0, 3)
}

draw :: () {
	if glGetUniformLocation == null
		return

    update()

    SwapBuffers(dc)
}

get_cursor_position :: () {
    p: POINT
    GetCursorPos(&p)
    ScreenToClient(window, &p)
    return V2s(p.x, window_size.y - p.y)
}

window: HWND

main :: (): _: Int {
	class_name: = "window_class".data
	window_name: = "hello window".data

	hInstance: = GetModuleHandleA(null)

	wc: WNDCLASSEXA
	wc.hInstance = hInstance
	wc.cbSize = #sizeof WNDCLASSEXA
	wc.lpfnWndProc = //DefWindowProcA
    (hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {
        //return DefWindowProcA(hwnd, uMsg, wParam, lParam)
        // print(uMsg)
        // print_char('\n')
		if uMsg == WM_DESTROY {
			PostQuitMessage(0)
		} else if uMsg == WM_SIZE {
            window_size.x = (lParam & 0xffff) as S32
            window_size.y = ((lParam >> 16) & 0xffff) as S32
            draw()
        } else {
            return DefWindowProcA(hwnd, uMsg, wParam, lParam)
        }
        return 0
	}
	wc.lpszClassName = class_name
	wc.hCursor = LoadCursorA(null, IDC_ARROW)

    print(if RegisterClassExA(&wc) != 0 then "Class created!\n" else "Class Failed!\n")

	window = CreateWindowExA(
		0, class_name, window_name, WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, null, null, hInstance, null
	)

	print(if window != null then "Window Success!\n" else "Window Fail!\n")



    mouse: RAWINPUTDEVICE
    mouse.usUsagePage = 0x01
    mouse.usUsage = 0x02
    print(if RegisterRawInputDevices(&mouse, 1, #sizeof RAWINPUTDEVICE) != 0 then "Input success\n" else "Input fail\n")



	dp : PIXELFORMATDESCRIPTOR
	dp.nSize = #sizeof #typeof dp
	dp.nVersion = 1
	dp.dwFlags = PFD_SUPPORT_OPENGL | PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER
	dp.cColorBits = 32
	dp.cAlphaBits = 8
	dp.cDepthBits = 24
	dp.cStencilBits = 8
	dp.iPixelType = PFD_TYPE_RGBA
	dp.iLayerType = PFD_MAIN_PLANE

    dc = GetDC(window)

    index := ChoosePixelFormat(dc, &dp)
	if index == 0 {
		error := GetLastError()
		print("ChoosePixelFormat failed with code ")
		print(error)
		return 1
	}

	sp : PIXELFORMATDESCRIPTOR
	if DescribePixelFormat(dc, index, #sizeof #typeof sp, &sp) == 0
        print("DescribePixelFormat failed\n")

	if SetPixelFormat(dc, index, &sp) == 0
        print("SetPixelFormat failed\n")


	context := wglCreateContext(dc)
	if wglMakeCurrent(dc, context) != 1 {
		print("wglMakeCurrent failed")
		return 1
	}

	load_opengl_functions()

	if wglCreateContextAttribsARB != null {
		share: HGLRC
		context_attribs: [16]GLint
		context_attribs[0] = WGL_CONTEXT_MAJOR_VERSION_ARB; context_attribs[1] = 3
		context_attribs[2] = WGL_CONTEXT_MINOR_VERSION_ARB; context_attribs[3] = 0
		context_attribs[4] = WGL_CONTEXT_FLAGS_ARB;         context_attribs[5] = WGL_CONTEXT_DEBUG_BIT_ARB
		context_attribs[6] = WGL_CONTEXT_PROFILE_MASK_ARB;  context_attribs[7] = WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB
		context_attribs[8] = 0
		new_context := wglCreateContextAttribsARB(dc, share, context_attribs.data)
		if new_context != null {
			wglMakeCurrent(dc, new_context)
			wglDeleteContext(context)
			context = new_context

			//glEnable(GL_DEBUG_OUTPUT)
			//glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS)
			//glDebugMessageCallback(default_debug_proc, null)
			//glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, null, GL_TRUE)
		}
	}

	vao: GLuint
	glGenVertexArrays(1, &vao)
	glBindVertexArray(vao)

    buf: GLuint
    glGenBuffers(1, &buf)
    glBindBuffer(GL_ARRAY_BUFFER, buf)

    Vertex :: struct {
        x: F32
        y: F32
    }

    verts: [3]Vertex
    verts[0] = Vertex(-0.5, -0.5)
    verts[1] = Vertex( 0.0,  0.5)
    verts[2] = Vertex( 0.5, -0.5)

    glBufferData(GL_ARRAY_BUFFER, #sizeof #typeof verts, @verts.data, GL_STATIC_DRAW)

	glEnableVertexAttribArray(0)
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, #sizeof Vertex, @0)

	vs := create_shader(GL_VERTEX_SHADER, "
#version 330 core
uniform vec4 u_color;
layout(location=0) in vec2 vertex_position;
void main() {
	vec2 positions[] = vec2[](
		vec2(-1,-1),
		vec2(-1, 3),
		vec2( 3,-1)
	);
	gl_Position.xy = positions[gl_VertexID];
}
")
	fs := create_shader(GL_FRAGMENT_SHADER, "
#version 330 core
uniform vec4 u_color;
out vec4 fragment_color;
void main() {
	fragment_color = u_color;
}
")
	program = create_program(ProgramStages(vertex=vs, fragment=fs))
	glUseProgram(program)

	start()

	while true {
        msg : MSG
		while PeekMessageA(&msg, null, 0, 0, PM_REMOVE) != 0 {
            mouse_went_down := false
            mouse_went_up   := false
            defer {
                if mouse_went_down SetCapture(window)
                if mouse_went_up   ReleaseCapture()
            }

			if msg.message == WM_QUIT {
				return 0
            } else if msg.message == WM_INPUT {
                rawInput: RAWINPUT
                rawInputSize: UINT = #sizeof RAWINPUT
                if GetRawInputData(msg.lParam as HRAWINPUT, RID_INPUT, &rawInput, &rawInputSize, #sizeof RAWINPUTHEADER) == -1 {
                    print("Error: GetRawInputData\n")
                }
                if rawInput.header.dwType == RIM_TYPEMOUSE {
                    m := rawInput.data.mouse

                    // window->mouse_delta += V2f(mouse.lLastX, mouse.lLastY) * window->mouse_sensitivity

                    //if m.u.s.usButtonFlags & RI_MOUSE_BUTTON_1_UP != 0 { mouse_went_up = true on_mouse_up(0) }
                    //if m.u.s.usButtonFlags & RI_MOUSE_BUTTON_2_UP != 0 { mouse_went_up = true on_mouse_up(1) }
                    //if m.u.s.usButtonFlags & RI_MOUSE_BUTTON_3_UP != 0 { mouse_went_up = true on_mouse_up(2) }
                }
            }
            else if msg.message == WM_LBUTTONDOWN { mouse_went_down = true; on_mouse_down(0) }
            else if msg.message == WM_RBUTTONDOWN { mouse_went_down = true; on_mouse_down(1) }
            else if msg.message == WM_MBUTTONDOWN { mouse_went_down = true; on_mouse_down(2) }
            else if msg.message == WM_LBUTTONUP   { mouse_went_up   = true; on_mouse_up  (0) }
            else if msg.message == WM_RBUTTONUP   { mouse_went_up   = true; on_mouse_up  (1) }
            else if msg.message == WM_MBUTTONUP   { mouse_went_up   = true; on_mouse_up  (2) }

			TranslateMessage(&msg)
			DispatchMessageA(&msg)
		}

        draw()
	}
}
