# Build the manager binary
FROM --platform=$BUILDPLATFORM golang:1.23 AS builder

ARG TARGETOS TARGETARCH

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY webhooks/ webhooks/

# Build
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -o gcp-workload-identity-federation-webhook main.go

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot
WORKDIR /
COPY --from=builder /workspace/gcp-workload-identity-federation-webhook .
USER 65532:65532

ENTRYPOINT ["/gcp-workload-identity-federation-webhook"]
