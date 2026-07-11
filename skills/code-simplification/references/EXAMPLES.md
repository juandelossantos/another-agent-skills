# Before and After Examples

All three follow Beck's rules: intention is clearer (Rule 2), duplication is removed (Rule 3), and every element serves a clear purpose (Rule 4).

## 1. Nested Conditionals → Guard Clauses

**Before (cyclomatic: 4, cognitive: 4):**
```python
def process_order(order, user):
    if order is not None:
        if user is not None:
            if order.status == "pending":
                charge_user(user, order.total)
                order.status = "paid"
                send_confirmation(user.email, order)
            else:
                raise ValueError("order already processed")
        else:
            raise ValueError("user required")
    else:
        raise ValueError("order required")
```

**After (cyclomatic: 3, cognitive: 1):**
```python
def process_order(order, user):
    if order is None:
        raise ValueError("order required")
    if user is None:
        raise ValueError("user required")
    if order.status != "pending":
        raise ValueError("order already processed")
    charge_user(user, order.total)
    order.status = "paid"
    send_confirmation(user.email, order)
```

## 2. Duplicated Logic → Extract Function

**Before:**
```python
def calculate_discount(cart, user_type):
    total = sum(item.price for item in cart)
    if user_type == "premium":
        discount = total * 0.2
        tax = discount * 0.08
        return total - discount + tax
    elif user_type == "regular":
        discount = total * 0.1
        tax = discount * 0.08
        return total - discount + tax
    else:
        tax = total * 0.08
        return total + tax
```

**After:**
```python
def calculate_discount(cart, user_type):
    total = sum(item.price for item in cart)
    discount = discount_rate(user_type) * total
    tax = discount * 0.08
    return total - discount + tax

def discount_rate(user_type):
    rates = {"premium": 0.2, "regular": 0.1}
    return rates.get(user_type, 0)
```

## 3. Flag Parameters → Separate Functions

**Before:**
```python
def render_report(data, format_type, include_summary):
    if format_type == "html":
        output = f"<h1>{data['title']}</h1>"
        for row in data["rows"]:
            output += f"<p>{row}</p>"
        if include_summary:
            output += f"<p>Total: {sum(data['rows'])}</p>"
        return output
    elif format_type == "text":
        output = f"Title: {data['title']}\n"
        for row in data["rows"]:
            output += f"- {row}\n"
        if include_summary:
            output += f"Total: {sum(data['rows'])}\n"
        return output
```

**After:**
```python
def render_html_report(data, include_summary=False):
    output = f"<h1>{data['title']}</h1>"
    for row in data["rows"]:
        output += f"<p>{row}</p>"
    if include_summary:
        output += f"<p>Total: {sum(data['rows'])}</p>"
    return output

def render_text_report(data, include_summary=False):
    output = f"Title: {data['title']}\n"
    for row in data["rows"]:
        output += f"- {row}\n"
    if include_summary:
        output += f"Total: {sum(data['rows'])}\n"
    return output
```
