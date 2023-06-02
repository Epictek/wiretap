FROM node:20-bullseye-slim as builder

# set up ui build
RUN mkdir -p /wt_build
WORKDIR /wt_build
COPY ui/ ./ui
RUN npm install yarn
WORKDIR /wt_build/ui

# run ui build
RUN yarn install
RUN yarn build

FROM golang:1.20-alpine

WORKDIR /work

COPY --from=builder /wt_build/ui ./

COPY . ./

RUN go mod download && go mod verify
RUN go build -ldflags="-w -s" -v -o /wiretap wiretap.go

ENV PATH=$PATH:/

ENTRYPOINT ["wiretap"]