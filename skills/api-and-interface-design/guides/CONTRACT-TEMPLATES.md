# Contract Templates

> **Sources:** OpenAPI Specification 3.x (openapis.org) — HTTP API contract format. GraphQL Schema Definition Language (graphql.org/learn/schema). Protobuf Language Guide (protobuf.dev). Google API Design Guide (google.aip.dev) — resource-oriented design conventions.

## REST — OpenAPI 3.x

```yaml
openapi: "3.1.0"
info:
  title: "Orders API"
  version: "1.0.0"
paths:
  /orders:
    get:
      summary: "List orders"
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [pending, completed, cancelled]
      responses:
        "200":
          description: "List of orders"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Order"
components:
  schemas:
    Order:
      type: object
      required: [id, status, total]
      properties:
        id:
          type: string
          format: uuid
        status:
          type: string
          enum: [pending, completed, cancelled]
        total:
          type: number
```

Key conventions: use `$ref` for shared schemas, always define error responses, use standard HTTP status codes.

## GraphQL

```graphql
type Order {
  id: ID!
  status: OrderStatus!
  total: Float!
  items: [OrderItem!]!
}

enum OrderStatus {
  PENDING
  COMPLETED
  CANCELLED
}

type OrderItem {
  productId: ID!
  quantity: Int!
  price: Float!
}

type Query {
  orders(status: OrderStatus): [Order!]!
}

type Mutation {
  createOrder(items: [OrderItemInput!]!): Order!
}

input OrderItemInput {
  productId: ID!
  quantity: Int!
}
```

Key conventions: non-null by default, separate Input types from response types, pagination with `first`/`after` pattern.

## gRPC / Protobuf

```protobuf
syntax = "proto3";
package orders.v1;

service OrderService {
  rpc ListOrders(ListOrdersRequest) returns (ListOrdersResponse);
  rpc CreateOrder(CreateOrderRequest) returns (Order);
}

message Order {
  string id = 1;
  OrderStatus status = 2;
  double total = 3;
}

enum OrderStatus {
  ORDER_STATUS_UNSPECIFIED = 0;
  ORDER_STATUS_PENDING = 1;
  ORDER_STATUS_COMPLETED = 2;
}

message ListOrdersRequest {
  int32 page_size = 2;
  string page_token = 3;
}

message ListOrdersResponse {
  repeated Order orders = 1;
  string next_page_token = 2;
}
```

Key conventions: stable field numbers, first enum value UNSPECIFIED = 0, use message pairs for request/response.

## Contract Testing

Contract tests verify the API response matches the documented contract. Run them in CI:

```yaml
test:
  request: POST /api/orders { items: [{ productId: "p1", quantity: 2 }] }
  expected_status: 201
  expected_body:
    id: "/\\A[0-9a-f-]{36}\\z/"
    status: pending
```
