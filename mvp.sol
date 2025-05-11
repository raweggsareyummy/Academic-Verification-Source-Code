// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Academic Credential Verification System on Hedera
/// @notice This contract allows universities to issue and verify student credentials

contract AcademicVerification {
    
    // Owner of the contract (university)
    address public universityAdmin;

    // Event emitted when a credential is issued
    event CredentialIssued(address indexed student, string degree, uint256 dateIssued);

    // Structure to hold credential information
    struct Credential {
        string degree;
        uint256 dateIssued;
        bool isValid;
    }

    // Mapping from student address to their credentials
    mapping(address => Credential) private credentials;

    // Modifier to restrict access to university admin
    modifier onlyUniversity() {
        require(msg.sender == universityAdmin, "Only the university can perform this action.");
        _;
    }

    /// @notice Constructor sets the university admin
    constructor() {
        universityAdmin = msg.sender;
    }

    /// @notice Issue a credential to a student
    /// @param student The address of the student
    /// @param degree The degree or certificate awarded
    function issueCredential(address student, string memory degree) public onlyUniversity {
        credentials[student] = Credential(degree, block.timestamp, true);
        emit CredentialIssued(student, degree, block.timestamp);
    }

    /// @notice Revoke a credential (e.g., for fraud or error)
    /// @param student The address of the student
    function revokeCredential(address student) public onlyUniversity {
        require(credentials[student].isValid, "Credential already revoked or not found.");
        credentials[student].isValid = false;
    }

    /// @notice Public function to verify if a student's credential is valid
    /// @param student The address of the student
    /// @return degree The name of the degree
    /// @return dateIssued When the degree was issued
    /// @return isValid Whether the credential is currently valid
    function verifyCredential(address student) public view returns (string memory degree, uint256 dateIssued, bool isValid) {
        Credential memory cred = credentials[student];
        return (cred.degree, cred.dateIssued, cred.isValid);
    }

    /// @notice Change the university admin (e.g., in case of migration)
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) public onlyUniversity {
        require(newAdmin != address(0), "Invalid address");
        universityAdmin = newAdmin;
    }
}
