package io.platform.platform_api.kubernetes;

import org.springframework.stereotype.Component;

import io.fabric8.knative.client.KnativeClient;
import io.fabric8.knative.serving.v1.ServiceBuilder;
import io.platform.platform_api.dto.AppCreateRequest;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class KnativeHelper {

    private final KnativeClient knativeClient;

    public boolean checkAppExists(AppCreateRequest request) {
        return knativeClient.services()
                .inNamespace(request.getNamespace())
                .withName(request.getAppName())
                .get() != null;
    }

    public io.fabric8.knative.serving.v1.Service createKnativeService(AppCreateRequest request) {
        return new ServiceBuilder()
            .withNewMetadata()
                .withName(request.getAppName())
                .withNamespace(request.getNamespace())
            .endMetadata()
            .withNewSpec()
                .withNewTemplate()
                    .withNewSpec()
                        .addNewContainer()
                            .withImage(request.getImageRef())
                            .addNewPort()
                                .withContainerPort(request.getContainerPort()) 
                            .endPort()
                        .endContainer()
                    .endSpec()
                .endTemplate()
            .endSpec()
            .build();
    }
}
