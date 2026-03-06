const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sayabletime_mod = b.addModule("sayabletime", .{
        .root_source_file = b.path("src/sayabletime.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/test_format_time.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sayabletime", .module = sayabletime_mod },
        },
    });

    const tests = b.addTest(.{
        .root_module = test_mod,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}
