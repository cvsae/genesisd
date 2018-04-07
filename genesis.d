// Copyright (c) 2009 CVSC
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

import std.stdio;
import std.conv : to;
import std.digest.sha;
import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.bitmanip;
import std.uni;
import core.stdc.stdint;
import core.stdc.stdlib;




// encode hex 
string encodeHex(string i){return (cast(ubyte[]) i).toHexString;}
// decode hex 
string decodeHex(string i){return to!string(i.chunks(2).map!(digits => cast(char) digits.to!ubyte(16)).array);}


class CBlock{

  // block header 
  uint32_t nVersion;
  string hashPrevBlock;
  string hashMerkleRoot;
  uint32_t nTime;
  uint32_t nBits;
  uint32_t nNonce;


  string getHeader(){


    byte[] header;
    
    header ~= nativeToLittleEndian(nVersion);
    header ~= to!string(hashPrevBlock.chunks(2).array.retro.joiner).decodeHex;
    header ~= to!string(hashMerkleRoot.chunks(2).array.retro.joiner).decodeHex;
    header ~= nativeToLittleEndian(nTime);
    header ~= nativeToLittleEndian(nBits);
    header ~= nativeToLittleEndian(nNonce);

    return toLower((cast(ubyte[]) header).toHexString);
  }


  string GetHash(){

    auto sha256 = new SHA256Digest();
    return toLower(to!string(toHexString(sha256.digest(sha256.digest(getHeader.decodeHex))).chunks(2).array.retro.joiner));

  }
}


class CTransaction{

  uint32_t nVersion;
  int num_ins = 01;
  int num_ous = 01;
  string prev_output;
  string ins;
  string ous;
  long nValue;
  uint32_t locktime = 0;



  string getHeader(){

    byte[] header;
    
    header ~= nativeToLittleEndian(nVersion);
    header ~= to!byte(num_ins);
    header ~= prev_output .decodeHex;
    header ~= "FFFFFFFF".decodeHex;
    header ~= "4d".decodeHex;
    header ~= ins.encodeHex.decodeHex;
    header ~= "FFFFFFFF".decodeHex;
    header ~= to!byte(num_ous);
    header ~= toHexString(nativeToLittleEndian(nValue)).decodeHex;
    header ~= "43".decodeHex;
    header ~= ous.decodeHex;
    header ~= nativeToLittleEndian(locktime);
    return toLower((cast(ubyte[]) header).toHexString);
  }


  
  string GetHash(){

    auto sha256 = new SHA256Digest();
    return toLower(to!string(toHexString(sha256.digest(sha256.digest(getHeader.decodeHex))).chunks(2).array.retro.joiner));

  }
}



void main() {

  string pszTimestamp = "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks";


  CTransaction txNew = new CTransaction();
  // create new transaction
  txNew.nVersion = 1;
  txNew.nValue = 5000000000;
  txNew.prev_output = "0000000000000000000000000000000000000000000000000000000000000000"; 
  txNew.ins = ("04ffff001d0104" ~ to!string(cast(char)(to!int(pszTimestamp.length))).encodeHex ~ pszTimestamp.encodeHex).decodeHex; // input script 
  txNew.ous = "41" ~"04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f" ~"ac".encodeHex.decodeHex; // output script

    
  CBlock block = new CBlock();
  // create new block 
  block.nVersion = 1;
  block.hashPrevBlock = "0000000000000000000000000000000000000000000000000000000000000000";
  block.hashMerkleRoot = txNew.GetHash();
  block.nTime = 1231006505;
  block.nBits = 0x1d00ffff;
  block.nNonce = 2083236893;

  //writeln(block.getHeader()); // block header hex 
  //writeln(block.GetHash());  // block hash 
  //writeln(txNew.getHeader); // transaction header hex 

  

  if(block.nNonce == 2083236893){
    assert(block.GetHash() == "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f");
    assert(block.hashMerkleRoot == "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b");
    writeln(block.GetHash());
    exit(1);
  }

  writeln("Searching for genesis block");
  
  while (true){  

    // The hash is already know, if the hash wasn't know, we have to do block.GetHash() <= hashTarget hashTarget is derived from block.nBits
    if(block.GetHash() == "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"){

      writeln("Genesis hash found");
      writeln("Nonce: ", block.nNonce);
      writeln("Genesis hash: ", block.GetHash());
      exit(1);
    }
    
    block.nNonce ++;
  }
}
