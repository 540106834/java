package com.jsy.demo;

import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api")
public class DemoController {
   
    @GetMapping("/health")
    public String health() {
        return "status 200 UP";
    }

}

