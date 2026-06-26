package io.platform.platform_api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.fabric8.knative.client.KnativeClient;
import io.fabric8.kubernetes.client.KubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClientBuilder;

@Configuration
public class KubeConfig {
    @Bean(destroyMethod = "close")
    public KnativeClient knativeClient() {
        KubernetesClient k8sClient = new KubernetesClientBuilder().build();
        KnativeClient knativeClient = k8sClient.adapt(KnativeClient.class);
        return knativeClient;
    }
}
