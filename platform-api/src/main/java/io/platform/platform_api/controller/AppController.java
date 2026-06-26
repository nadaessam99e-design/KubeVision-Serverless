package io.platform.platform_api.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.platform.platform_api.dto.AppCreateRequest;
import io.platform.platform_api.service.AppService;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/app")
@RequiredArgsConstructor 
public class AppController {
    
    private final AppService appService;
    
    @PostMapping("/create")
    public ResponseEntity<String> createApp(@RequestBody AppCreateRequest request) {
        
        boolean isCreated = appService.createApp(request);

        if (isCreated) {
            String appUrl = "https://" + request.getAppName() + ".creative.opik.net";
            String responseBody = String.format(
                "{\"message\": \"Application deployed successfully\", \"url\": \"%s\"}", 
                appUrl
            );

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(responseBody);
        } else {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("{\"error\": \"Application already exists in this namespace\"}");
        }
    }

    @DeleteMapping("/")
    public ResponseEntity<String> deleteApp(@RequestBody AppCreateRequest request) {
        boolean isDeleted = appService.deleteApp(request);

        if (isDeleted) {
            return ResponseEntity.ok("{\"message\": \"Application deleted successfully\"}");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("{\"error\": \"Application not found in this namespace\"}");
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("{\"status\": \"UP\"}");
    }
    
}
