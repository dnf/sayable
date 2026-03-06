const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sayabledate_mod = b.addModule("sayabledate", .{
        .root_source_file = b.path("src/sayabledate.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/test_format_date.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sayabledate", .module = sayabledate_mod },
        },
    });

    const tests = b.addTest(.{
        .root_module = test_mod,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}
