# import cairo
import gi
# gi.require_version("Gtk", "3.0")
# gi.require_version("Gdk", "3.0")
from gi.repository import GLib, Gdk, Gtk
from OpenGL.GL import *
from OpenGL.GL import shaders
import numpy as np
# import traceback

# Vertex Shader
VERTEX_SHADER = """
#version 330 core
layout(location = 0) in vec2 position;
uniform vec2 resolution;

void main() {
    gl_Position = vec4(position * 3., 0.0, 1.0);
}
"""


class GShaderPaper(Gtk.Window):
    def __init__(self, fragment_shader_src, fps):
        Gtk.Window.__init__(self)
        self.fragment_shader_src = fragment_shader_src
        self.fps = fps
        self.screen_size = self.get_screen_size(Gdk.Display.get_default())
        self.set_default_size(self.screen_size[0], self.screen_size[1])
        self.set_app_paintable(True)
        self.set_decorated(False)  # Remove window decorations
        self.set_keep_below(True)  # Keep the window below other windows
        self.set_type_hint(Gdk.WindowTypeHint.DESKTOP)  # Make it act like a wallpaper

        # Enable transparency
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual and screen.is_composited():
            self.set_visual(visual)

        self.vertices = [1.0, 1.0, 0.0, 1.0, -1.0, 1.0, 0.0, 1.0, 0.0, -1.0, 0.0, 1.0]
        self.vertices = np.array(self.vertices, dtype=np.float32)

        # OpenGL context
        self.gl_area = Gtk.GLArea()
        self.gl_area.set_required_version(3, 3)
        self.gl_area.set_auto_render(True)
        self.gl_area.connect("realize", self.on_realize)
        self.gl_area.connect("render", self.on_render)
        self.add(self.gl_area)

        # Shader program
        self.shader_program = None
        self.time = 0.0

        # Timer for animation
        # GLib.timeout_add(1000.0 / self.fps, self.update)  # 16 ms ~= 60 FPS

    def update_fragment_shader(self, fragment_shader_src):
        self.fragment_shader_src = fragment_shader_src
        try:
            print("Compiling shaders...")
            self.shader_program = self.compile_shaders()
            print("Compiled shaders.")
        except shaders.ShaderValidationError as error:
            print(f"Shader validation error: {error}")
            # traceback.print_exc()
            # print(traceback.format_exc())
            pass
        except shaders.ShaderCompilationError as error:
            print(f"Shader compilation error: {error}")
            # traceback.print_exc()
            # print(traceback.format_exc())
            pass

    def on_realize(self, widget):
        # print("realize event")
        widget.make_current()

        GLib.timeout_add(1000.0 / self.fps, self.update)  # 16 ms ~= 60 FPS

        self.update_fragment_shader(self.fragment_shader_src)

        self.vao = glGenVertexArrays(1)
        glBindVertexArray(self.vao)

        self.vbo = glGenBuffers(1)
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)

        self.position = glGetAttribLocation(self.shader_program, "position")
        glEnableVertexAttribArray(self.position)
        glVertexAttribPointer(self.position, 4, GL_FLOAT, False, 0, ctypes.c_void_p(0))
        glBufferData(GL_ARRAY_BUFFER, 48, self.vertices, GL_STATIC_DRAW)
        # glBindVertexArray(0)
        # glDisableVertexAttribArray(self.position)
        glBindBuffer(GL_ARRAY_BUFFER, 0)
        return True

    def on_render(self, gl_area, context):
        # print('render event')
        if not self.shader_program:
            return

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glUseProgram(self.shader_program)

        # Pass uniforms to the shader
        time_loc = glGetUniformLocation(self.shader_program, "time")
        glUniform1f(time_loc, self.time)
        resolution_loc = glGetUniformLocation(self.shader_program, "resolution")
        glUniform2f(resolution_loc, self.screen_size[0], self.screen_size[1])

        glBindVertexArray(self.vao)
        glDrawArrays(GL_TRIANGLES, 0, 3)
        # glBindVertexArray(0)

        glUseProgram(0)
        glFlush()

        return True

    def compile_shaders(self):
        vertex_shader = shaders.compileShader(VERTEX_SHADER, GL_VERTEX_SHADER)
        fragment_shader = shaders.compileShader(
            self.fragment_shader_src, GL_FRAGMENT_SHADER
        )
        return shaders.compileProgram(vertex_shader, fragment_shader)

    def update(self):
        self.time += 1000.0 / self.fps  # Increment time for animation
        self.gl_area.queue_render()
        return True

    def get_screen_size(self, display):
        mon_geoms = [
            display.get_monitor(i).get_geometry()
            for i in range(display.get_n_monitors())
        ]
        x0 = min(r.x for r in mon_geoms)
        y0 = min(r.y for r in mon_geoms)
        x1 = max(r.x + r.width for r in mon_geoms)
        y1 = max(r.y + r.height for r in mon_geoms)
        return x1 - x0, y1 - y0
