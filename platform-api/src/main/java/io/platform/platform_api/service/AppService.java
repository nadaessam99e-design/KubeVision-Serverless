package io.platform.platform_api.service;

import org.springframework.stereotype.Service;
import io.fabric8.knative.client.KnativeClient;
import io.platform.platform_api.dto.AppCreateRequest;
import io.platform.platform_api.kubernetes.KnativeHelper;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AppService {
    
    private final KnativeClient knativeClient;
    private final KnativeHelper knativeHelper;
    public boolean deleteApp(AppCreateRequest request) {

        if (!knativeHelper.checkAppExists(request)) {
            return false;
        }

        knativeClient.services()
                .inNamespace(request.getNamespace())
                .withName(request.getAppName())
                .delete();
        return true;
    }
    public boolean createApp(AppCreateRequest request) {
        if (knativeHelper.checkAppExists(request)) {
            return false;
        }

        io.fabric8.knative.serving.v1.Service knativeService = 
            knativeHelper.createKnativeService(request);

        knativeClient.services()
                .inNamespace(request.getNamespace())
                .resource(knativeService)
                .create();
                
        // TODO: Save app details to database and return the deployed URL
        
        return true;
    }
}