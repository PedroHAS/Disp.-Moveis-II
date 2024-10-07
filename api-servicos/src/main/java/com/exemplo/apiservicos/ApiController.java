package com.exemplo.apiservicos;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {

    @GetMapping("/data")
    public List<Map<String, String>> getData() {
        List<Map<String, String>> data = new ArrayList<>();

        Map<String, String> item1 = new HashMap<>();
        item1.put("id", "1");
        item1.put("name", "Produto 1");

        Map<String, String> item2 = new HashMap<>();
        item2.put("id", "2");
        item2.put("name", "Produto 2");

        data.add(item1);
        data.add(item2);

        return data;
    }
}
