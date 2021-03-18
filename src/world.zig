const std = @import("std");
const c = @import("c.zig");

const log = std.log.scoped(.world);

const ErrorCallback = fn (err: c_int, description: [*c]const u8) callconv(.C) void;
const ResizeCallback = fn (target: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void;

pub const World = struct {
    size: [2]i32 = .{ 1600, 900 },
    window: *c.GLFWwindow = undefined,

    pub fn init(errorCallback: ErrorCallback, resizeCallback: ResizeCallback) !World {
        var self = World{};

        _ = c.glfwSetErrorCallback(errorCallback);

        if (c.glfwInit() == c.GL_FALSE) {
            log.crit("Failed to initialize GLFW\n", .{});

            return error.InitFailed;
        }
        errdefer c.glfwTerminate();

        setHints();

        self.window = c.glfwCreateWindow(self.size[0], self.size[1], "Crashy", null, null) orelse {
            log.crit("Failed to create GLFW window\n", .{});

            return error.CreateWindowFailed;
        };
        errdefer c.glfwDestroyWindow(self.window);

        _ = c.glfwSetFramebufferSizeCallback(self.window, resizeCallback);

        c.glfwMakeContextCurrent(self.window);

        self.setupGlContext();

        return self;
    }

    fn setHints() void {
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
        c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE);
    }

    fn setupGlContext(self: World) void {
        c.glViewport(0, 0, self.size[0], self.size[1]);

        c.glfwSwapInterval(1);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
    }

    pub fn run(self: World) !bool {
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glfwSwapBuffers(self.window);

        c.glfwPollEvents();

        return c.glfwWindowShouldClose(self.window) == c.GL_FALSE;
    }

    pub fn update(self: World) !void {
        if (c.glfwGetKey(self.window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
            c.glfwSetWindowShouldClose(self.window, 1);

            log.info("Quitting...", .{});
        }
    }

    pub fn resize(self: World, width: i32, height: i32) void {
        self.size = .{ width, height };

        c.glViewport(0, 0, width, height);
    }

    pub fn deinit(self: World) void {
        c.glfwDestroyWindow(self.window);
        c.glfwTerminate();
    }
};
