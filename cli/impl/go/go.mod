module github.com/dnf/sayable/cli/impl/go

go 1.21

require (
	github.com/dnf/sayable/age/impl/go v0.0.0
	github.com/dnf/sayable/date/impl/go v0.0.0
	github.com/dnf/sayable/duration/impl/go v0.0.0
	github.com/dnf/sayable/time/impl/go v0.0.0
)

replace (
	github.com/dnf/sayable/age/impl/go => ../../../age/impl/go
	github.com/dnf/sayable/date/impl/go => ../../../date/impl/go
	github.com/dnf/sayable/duration/impl/go => ../../../duration/impl/go
	github.com/dnf/sayable/time/impl/go => ../../../time/impl/go
)
