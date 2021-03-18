const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

const std = @import("std");

const log = std.log.scoped(.main);

var window: *c.GLFWwindow = undefined;

export fn errorCallback(err: c_int, description: [*c]const u8) void {
    // TODO: figure out how to get a *const [u8] from the [*c]const u8
    @panic("Some error occurred. Good luck!");
}

pub fn main() anyerror!void {
    log.info("Start!", .{});

    _ = c.glfwSetErrorCallback(errorCallback);

    log.debug("Error callback set", .{});

    if (c.glfwInit() == c.GL_FALSE) {
        log.crit("Failed to initialize GLFW\n", .{});

        return error.InitFailed;
    }

    defer c.glfwTerminate();

    log.debug("Setting hints..", .{});

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 2);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 0);

    log.debug("GL Hints set", .{});

    window = c.glfwCreateWindow(640, 580, "Crashy", null, null) orelse {
        log.crit("Failed to create GLFW window\n", .{});

        return error.CreateWindowFailed;
    };

    log.debug("Window created", .{});

    defer c.glfwDestroyWindow(window);

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);
    c.glClearColor(0.0, 0.0, 0.0, 0.0);

    log.debug("Context set, starting loop", .{});

    while (c.glfwWindowShouldClose(window) == c.GL_FALSE) {
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        c.glfwSwapBuffers(window);

        c.glfwPollEvents();
    }

    log.debug("Loop ended", .{});
    log.info("Done!", .{});
}
