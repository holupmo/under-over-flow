# Solidity Security Lab: Integer Overflow & Underflow

## Overview

This laboratory explores integer overflow and underflow vulnerabilities in Solidity smart contracts, focusing on unchecked arithmetic, integer boundaries, and the historical BatchOverflow vulnerability class.

The main objective was to understand how arithmetic errors can bypass balance verification and compromise smart contract business logic.

## Topics Covered

- Unsigned integer types (`uint8`, `uint256`)
- Integer overflow and underflow
- Wrapping arithmetic and modulo operations
- Checked arithmetic in Solidity 0.8+
- The `unchecked` keyword
- Panic errors (`0x11`)
- SafeMath library and its historical purpose
- BatchOverflow vulnerability
- Secure balance accounting
- Smart contract auditing and input validation

## Vulnerability Analysis

A vulnerable batch transfer implementation was examined using Solidity 0.7.6.

The critical operation was:

```solidity
uint256 total = receivers.length * amount;
```

In Solidity versions before 0.8.0, arithmetic operations could silently overflow.

An attacker could potentially cause the multiplication result to wrap around, making the calculated total significantly smaller than its mathematical value.

This could bypass the balance verification:

```solidity
require(
    balances[msg.sender] >= total,
    "Insufficient balance"
);
```

The contract would then credit each recipient using the original `amount`, potentially creating an inconsistent token accounting state.

Another vulnerable operation was identified:

```solidity
balances[receivers[i]] += amount;
```

Without arithmetic checks, this operation could also overflow an existing recipient balance.

## Root Cause

The primary root cause was the lack of automatic arithmetic overflow and underflow checks in older Solidity versions.

Additional issues included insufficient validation of aggregate transfer amounts and the absence of limits on batch operations.

## Remediation

The vulnerable implementation was rewritten using Solidity 0.8.20.

The fixed version includes:

- Built-in checked arithmetic.
- Verification of the aggregate transfer amount.
- A maximum batch recipient limit.
- Zero-address validation.
- Protected balance subtraction and addition.
- Atomic transaction execution.

The contract also uses `calldata` for read-only recipient arrays.

## Testing

The corrected contract was deployed and tested in Remix VM.

The following scenarios were verified:

| Test case | Expected result |
|---|---|
| Two recipients receiving 100 tokens each | Success |
| Two recipients receiving 600 tokens each | Revert |
| More than 100 recipients | Revert |
| Zero address as a recipient | Revert |
| Arithmetic overflow during recipient balance addition | Revert when the overflowing state is present |

The contract behaved as expected in the tested scenarios.

Note: testing recipient-balance overflow requires a test environment capable of initializing a recipient with a sufficiently large starting balance.

## Key Takeaways

Solidity 0.8.0 introduced built-in overflow and underflow protection, significantly reducing the risk of accidental arithmetic errors.

However, compiler-level protections do not guarantee complete smart contract security.

Developers and auditors must still examine business logic, input validation, type conversions, unchecked blocks, access control, and state consistency.

**Understanding arithmetic boundaries is an essential foundation for smart contract security auditing.**
