module LarsW.Test
{
    type Person
    {
        Id : Integer32 = AutoNumber();
        FirstName : Text#32;
        LastName : Text#32;
        EmailAddress : (Text#128)?;
    }
    where identity Id;
    
    Persons: Person*;
    
    type Company
    {
        Id : Integer32 = AutoNumber();
        Name : Text#64;
        Address : Addresses;
    }
    where identity Id;
    Companies: Company*;
    
    type Address
    {
        Id : Integer32 = AutoNumber();
        Line1 : Text#64;
        Line2: (Text#64)?;
        ZipCode: Text#10;
        City: Text#32;
        Country: Text#32;
    }
    where identity Id;
    Addresses: Address*;
}