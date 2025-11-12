@0xe6944af362745a7d;

struct PolicyContainer {
  # Compiler information
  zplcVerMajor @0 :UInt32;
  zplcVerMinor @1 :UInt32;
  zplcVerPatch @2 :UInt32;

  policy    @3 :Data;  # capnp encoded 'Policy'
  signature @4 :Data; # signature over 'policy'
}

struct Policy {
  created     @0 :Text; # timestamp
  version     @1 :UInt64;
  metadata    @2 :Text;
  comPolicies @3 :List(CPolicy);
  keys        @4 :List(KeyMaterial);
}

# "CPolicy" is a Communications Policy.
struct CPolicy {
  id           @0 :Text;
  serviceId    @1 :Text;
  zpl          @2 :Text;
  allow        @3 :Bool;
  scope        @4 :List(Scope);
  clientConds  @5 :List(AttrExpr);
  serviceConds @6 :List(AttrExpr);
  signal       @7 :Signal; # Don't need an is_signal because capnp has a has_signal func to see if this field is set
}

enum ScopeFlag {
  noFlag           @0;
  udpOneWay        @1;
  icmpRequestRepl  @2;
}

struct Scope {
  protocol @0 :UInt8;
  flag     @1 :ScopeFlag;
  union {
    port :group {
      portNum @2 :UInt16;
    }
    portRange :group {
        low   @3 :UInt16;
        high  @4 :UInt16;
    }
  }
}

enum AttrOp {
    eq       @0;
    ne       @1;
    has      @2;
    excludes @3;
}

struct AttrExpr {
  key   @0 :Text;
  op    @1 :AttrOp;
  value @2 :List(Text);
}

struct Signal {
  msg @0 :Text;
  svc @1 :Text;
}

enum KeyMaterialT {
  rsaPub @0;
}

enum KeyAllowance {
  bootstrap @0;
}

struct KeyMaterial {
  id        @0  :Text;
  keyType   @1  :KeyMaterialT;
  keyAllows @2  :List(KeyAllowance);
  keyData   @3  :Data;
}
