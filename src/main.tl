Particle :: struct {
	position: V2f
	velocity: V2f
}

particles: [64]Particle

hovers: Bool

rng: XorShift32

start :: () {
	rng.v = 1
}

update :: () {
	glViewport(0, 0, window_size.x, window_size.y)
	glClearColor(.3, .6, .9, 1)
	glClear(GL_COLOR_BUFFER_BIT)

	button := rect(min=window_size/2 as S32, size=V2s()).extend(v2s(100))

	hovers = get_cursor_position().in_bounds(button)

	color :=
		if hovers
		then V4f(1, 0, 0, 1)
		else V4f(.9, .8, .3, 1)

	glUniform4fv(glGetUniformLocation(program, "u_color".data), 1, color.data())

	draw_rect(button)
	for * p in particles {
		p.position = p.position + p.velocity
		gravity: F32 = 0.1
		p.velocity.y -= gravity
		draw_rect(rect(min=p.position as V2s, size=V2s(10, 10)))
	}
}

on_mouse_up :: (button: Int) {
}
on_mouse_down :: (button: Int) {
	if hovers {
		for * it in particles {
			it.position = get_cursor_position() as V2f
			it.velocity = rng.random_in_circle() * 10 as F32
		}
	}
}
