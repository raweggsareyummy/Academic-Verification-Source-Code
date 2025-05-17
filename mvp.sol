// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Academic Credential Verification System on Hedera
/// @notice This contract allows a university to issue, revoke, and verify multiple credentials per student address
contract AcademicVerification {

    // University admin
    address public universityAdmin;

    // Event emitted when a credential is issued
    event CredentialIssued(address indexed student, string degree, uint256 dateIssued);

    // Event emitted when a credential is revoked
    event CredentialRevoked(address indexed student, uint index);

    // Structure for each credential
    struct Credential {
        string degree;
        uint256 dateIssued;
        bool isValid;
    }

    // Each student (address) can have multiple credentials
    mapping(address => Credential[]) private credentials;

    // Restrict actions to university admin
    modifier onlyUniversity() {
        require(msg.sender == universityAdmin, "Only the university can perform this action.");
        _;
    }

    // Constructor sets the deployer as the admin
    constructor() {
        universityAdmin = msg.sender;
    }

    /// @notice Issue a new credential to a student
    /// @param student The student's address
    /// @param degree The name of the degree
    function issueCredential(address student, string memory degree) public onlyUniversity {
        credentials[student].push(Credential(degree, block.timestamp, true));
        emit CredentialIssued(student, degree, block.timestamp);
    }

    /// @notice Revoke a specific credential (by index) for a student
    /// @param student The student's address
    /// @param index Index of the credential in the array
    function revokeCredential(address student, uint index) public onlyUniversity {
        require(index < credentials[student].length, "Invalid credential index.");
        require(credentials[student][index].isValid, "Credential already revoked.");
        credentials[student][index].isValid = false;
        emit CredentialRevoked(student, index);
    }

    /// @notice View all credentials for a student
    /// @param student The student's address
    /// @return Array of Credential structs
    function getCredentials(address student) public view returns (Credential[] memory) {
        return credentials[student];
    }

    /// @notice Check if a student has a valid credential with a specific degree name
    /// @param student The student's address
    /// @param degree The degree name to verify
    /// @return found True if a valid matching credential exists
    function verifyCredential(address student, string memory degree) public view returns (bool found) {
        Credential[] memory creds = credentials[student];
        for (uint i = 0; i < creds.length; i++) {
            if (keccak256(bytes(creds[i].degree)) == keccak256(bytes(degree)) && creds[i].isValid) {
                return true;
            }
        }
        return false;
    }

    /// @notice Change university admin
    /// @param newAdmin The address of the new admin
    function changeAdmin(address newAdmin) public onlyUniversity {
        require(newAdmin != address(0), "Invalid address.");
        universityAdmin = newAdmin;
    }
}
