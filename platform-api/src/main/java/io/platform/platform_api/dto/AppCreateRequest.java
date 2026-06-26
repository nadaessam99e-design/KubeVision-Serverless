package io.platform.platform_api.dto;

import lombok.Data;

@Data 
public class AppCreateRequest {
    private String appName;
    private String namespace;
    private String imageRef;
    private int containerPort;
}