package me.snowdrop;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.domain.HttpExtension;
import me.snowdrop.model.Data;
import me.snowdrop.model.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.concurrent.atomic.AtomicInteger;

@RestController
public class OrderService {
    private static final String NODE_APP_ID = "nodeapp";
    private static final String SB_APP_ID = "springbootapp";
    private static final AtomicInteger ID_GENERATOR = new AtomicInteger(10);

    private static final Logger log = LoggerFactory.getLogger(OrderService.class);

    @GetMapping("/generateOrder")
    public ResponseEntity<String> createOrder() throws Exception {
        DaprClient client = new DaprClientBuilder().build();

        // byte[] response = client.invokeMethod(NODE_APP_ID, "neworder", convertOrder(populateOrder()), HttpExtension.POST, null,byte[].class).block();
        // return new ResponseEntity<>(response.toString(), HttpStatus.OK);

        client.invokeMethod(NODE_APP_ID, "neworder",populateOrder(),HttpExtension.POST,Order.class).block();
        return new ResponseEntity<>("Order posted", HttpStatus.OK);
    }

    private static Order populateOrder() throws Exception{
        Order order = new Order();
        Data data = new Data();
        data.setOrderId(Integer.toString(ID_GENERATOR.getAndIncrement()));
        order.setData(data);
        return order;
    }

    private static String convertOrder(Order order) throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        String json = mapper.writeValueAsString(order);
        log.info("Json order: " + json);
        return json;
    }
}