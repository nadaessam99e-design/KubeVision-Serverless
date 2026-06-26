package io.platform.platform_api.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "knative_apps")
@Data
public class AppEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; 
    
    private String appName;
    private String namespace;
    private String imageRef;
    private int containerPort;
    
    private AppStatus status;
    private String deployedUrl;
}