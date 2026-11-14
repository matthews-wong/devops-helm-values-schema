CHART := chart
ENVS := dev prod

.PHONY: validate lint render schema-tests rollout-test

validate: lint render schema-tests rollout-test

lint:
	helm lint $(CHART)
	@for e in $(ENVS); do helm lint $(CHART) -f $(CHART)/values-$$e.yaml || exit 1; done

render:
	@for e in $(ENVS); do \
		helm template t $(CHART) -f $(CHART)/values-$$e.yaml | kubeconform -strict -summary || exit 1; \
	done

schema-tests:
	tests/schema_cases.sh

rollout-test:
	tests/rollout_checksum.sh
