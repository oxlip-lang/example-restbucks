/*
 * Example of TypeSpec definition for the Restbucks imaginary coffee shop
 * https://www.infoq.com/articles/webber-rest-workflow/
 */

import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
  title: "Restbucks Service",
  version: "2023-10-20",
})
@server("https://example.com", "Example")
namespace Restbucks;

scalar internalID extends int32; // not supported: @doc("internal identifier")

@format("uri-reference")
scalar uri extends string;

@doc("drink") // not supported: @title("drink")
enum drink {
    "espresso",
    "latte",
}

@doc("addition to a drink")
enum addition {
    "shot",
}

@doc("price") // not supported: @example("4.45")
scalar price extends float64;

@doc("status of an order")
enum orderStatus { "created", "preparing", "ready" }

@doc("credit card number")
@pattern("^[0-9]{16}$")
scalar cardNo extends string;

@doc("credit card number")
@pattern("^[0-9]{16}$")
scalar cardExpiration extends string;

@doc("drink order")
model order {
    drink: drink;
    additions?: addition[];
    cost?: price;
    status?: orderStatus;
}

@doc("payment")
model payment {
    cardNo: cardNo;
    expires: cardExpiration;
    name: string;
    amount: price;
}

// not supported: @doc("order resource representation")
alias resOrder = order & {
    payment?: uri;
    edit?: uri;
};

@route("/orders")
namespace orders {
    @doc("Create an order")
    @post op create(@body _: { order: order }): /* not supported: @doc("Created") */ {
        @statusCode statusCode: 201;
        @header Location: uri; // cannot refer to routes
        @body _: { order: resOrder };
    };

    @doc("Retrieve all orders")
    @get op list(): {
        @statusCode statusCode: 200;
        @header Location: uri;
        @body _: { orders: resOrder[] };
    };

    @doc("Update an order")
    @put op update(@path id: internalID, @body _: { order: order }): {
        @statusCode statusCode: 200;
        @header Location: uri;
        @body _: { order: resOrder };
    } | {
        @statusCode statusCode: 409;
        @header Location: uri;
        @body _: { order: resOrder };
    };

    @doc("Delete an order")
    @delete op delete(@path id: internalID): {
        @statusCode statusCode: 200;
    };
}

@route("/payments")
namespace payments {
    @doc("Make a payment")
    @put op create(@body _: { payment: payment }): {
        @statusCode statusCode: 201;
        @header Location: uri;
        @body _: { payment: payment };
    };

    @doc("Retrieve a payment")
    @get op read(@path id: internalID): {
        @statusCode statusCode: 200;
        @header Location: uri;
        @body _: { payment: payment };
    };
}
