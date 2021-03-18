TEST?=$$(go list ./... |grep -v 'vendor')
GOFMT_FILES?=$$(find . -name '*.go' |grep -v vendor)
WEBSITE_REPO=github.com/hashicorp/terraform-website
PKG_NAME=schemaregistry

default: build

build: fmtcheck
	go install

test: fmtcheck
	go test -i $(TEST) || exit 1
	echo $(TEST) | \
		xargs -t -n4 go test $(TESTARGS) -timeout=30s -parallel=4

testacc: fmtcheck
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m

vet:
	@echo "go vet ."
	@go vet $$(go list ./... | grep -v vendor/) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

fmt:
	gofmt -w $(GOFMT_FILES)

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

errcheck:
	@sh -c "'$(CURDIR)/scripts/errcheck.sh'"

test-compile:
	@if [ "$(TEST)" = "./..." ]; then \
		echo "ERROR: Set TEST to a specific package. For example,"; \
		echo "  make test-compile TEST=./$(PKG_NAME)"; \
		exit 1; \
	fi
	go test -c $(TEST) $(TESTARGS)

website:
ifeq (,$(wildcard $(GOPATH)/src/$(WEBSITE_REPO)))
	echo "$(WEBSITE_REPO) not found in your GOPATH (necessary for layouts and assets), get-ting..."
	git clone https://$(WEBSITE_REPO) $(GOPATH)/src/$(WEBSITE_REPO)
endif
	@$(MAKE) -C $(GOPATH)/src/$(WEBSITE_REPO) website-provider PROVIDER_PATH=$(shell pwd) PROVIDER_NAME=$(PKG_NAME)

website-test:
ifeq (,$(wildcard $(GOPATH)/src/$(WEBSITE_REPO)))
	echo "$(WEBSITE_REPO) not found in your GOPATH (necessary for layouts and assets), get-ting..."
	git clone https://$(WEBSITE_REPO) $(GOPATH)/src/$(WEBSITE_REPO)
endif
	@$(MAKE) -C $(GOPATH)/src/$(WEBSITE_REPO) website-provider-test PROVIDER_PATH=$(shell pwd) PROVIDER_NAME=$(PKG_NAME)

BINARY=terraform-provider-schemaregistry
VERSION=$(shell git describe --tags --dirty)
PLATFORMS=darwin linux windows
ARCHITECTURES=amd64

wr-build-all: fmtcheck
	$(foreach GOOS, $(PLATFORMS),\
	$(foreach GOARCH, $(ARCHITECTURES), $(shell export GOOS=$(GOOS); export GOARCH=$(GOARCH); go build -v -o $(BINARY)_v$(VERSION)-$(GOOS)-$(GOARCH))))

TEST_PLATFORM=linux
TEST_ARCHITECTURE=amd64
TEST_VERSION=$(shell git describe --tags --dirty)
TEST_PLUGIN_SRC_PATH=~/.terraform.d/plugins/registry.terraform.io/hashicorp/schemaregistry

wr-test-import:
	mkdir -p ${TEST_PLUGIN_SRC_PATH}/${TEST_VERSION}/${TEST_PLATFORM}_${TEST_ARCHITECTURE}
	go build -o ${TEST_PLUGIN_SRC_PATH}/${TEST_VERSION}/${TEST_PLATFORM}_${TEST_ARCHITECTURE}/${BINARY}_v${TEST_VERSION}-${TEST_PLATFORM}-${TEST_ARCHITECTURE}
	cd examples; rm -rf .terraform; rm -f *.tfstate*
	cd examples; terraform init; terraform import 'schemaregistry_subject_schema.kafka_schemas["test-schema-prov"]' test-schema-prov

wr-test-plan:
	mkdir -p ${TEST_PLUGIN_SRC_PATH}/${TEST_VERSION}/${TEST_PLATFORM}_${TEST_ARCHITECTURE}
	go build -o ${TEST_PLUGIN_SRC_PATH}/${TEST_VERSION}/${TEST_PLATFORM}_${TEST_ARCHITECTURE}/${BINARY}_v${TEST_VERSION}-${TEST_PLATFORM}-${TEST_ARCHITECTURE}
	cd examples; rm -rf .terraform; rm -f *.tfstate*
	cd examples; terraform init; terraform plan;

wr-clean:
	cd examples; rm -rf .terraform; rm -f *.tfstate*

wr-rebuild:
	mkdir -p ${TEST_PLUGIN_SRC_PATH}/${TEST_VERSION}/${TEST_PLATFORM}_${TEST_ARCHITECTURE}
	go build -o ${TEST_PLUGIN_SRC_PATH}/${TEST_VERSION}/${TEST_PLATFORM}_${TEST_ARCHITECTURE}/${BINARY}_v${TEST_VERSION}-${TEST_PLATFORM}-${TEST_ARCHITECTURE}

.PHONY: build test testacc vet fmt fmtcheck errcheck test-compile website website-test